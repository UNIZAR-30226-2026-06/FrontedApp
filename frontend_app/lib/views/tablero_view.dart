import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/tablero_viewmodel.dart';
import '../viewmodels/partida_actual_viewmodel.dart';
import '../providers/auth_provider.dart';
import '../models/carta_model.dart';
import '../models/jugador_partida_model.dart';

import 'package:frontend_app/views/ajustes_overlay.dart';
import 'package:frontend_app/views/widgets/avatar_jugador_widget.dart';
import 'package:frontend_app/views/widgets/carta_widget.dart';
import 'package:frontend_app/views/widgets/chat_partida_widget.dart';
import 'package:frontend_app/views/widgets/mazo_central_widget.dart';
import 'package:frontend_app/views/widgets/panel_habilidad_rol.dart';
import 'package:frontend_app/views/widgets/tarjeta_rol_widget.dart';


class TableroView extends StatelessWidget {
  const TableroView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TableroViewModel>();
    final partidaVm = context.watch<PartidaActualViewModel>();
    final auth = context.watch<AuthProvider>();
    final partida = partidaVm.partidaActual;

    if (partida == null || partida.jugadores.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00FFFF)),
        ),
      );
    }

    final mensajeFeedback = partidaVm.mensajeFeedback;
    if (mensajeFeedback != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        partidaVm.consumirMensajeFeedback();
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(mensajeFeedback),
              duration: const Duration(milliseconds: 1500),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFFD65B5B),
            ),
          );
      });
    }

    final String miId = auth.usuario?.nombreUsuario ?? partida.jugadorLocal ?? '';
    final JugadorPartidaModel? miJugador = partida.jugadores
        .where((p) => p.id == miId)
        .firstOrNull;

    final List<JugadorPartidaModel> rivales = partida.jugadores
        .where((p) => p.id != miId)
        .toList();

    final bool esMiTurno = partida.esMiTurno(miId);

    bool esTurnoDeRival(String rivalId){
      return partida.currentTurn == rivalId;
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && partidaVm.partidaActual != null) {
          partidaVm.abandonarYBorrarPartida();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            _buildFondo(),

            if (partida.rolesMode)
              Positioned(
                top: 80,
                left: 16,
                child: TarjetaRolWidget(
                  role: partidaVm.miRol,
                  usos: partidaVm.usosRol,
                  maxUsos: partidaVm.maxUsosRol,
                  canUseNow: partidaVm.canUseRoleNow,
                  isRevealed: partidaVm.miRol != null,
                ),
              ),

            if (rivales.isNotEmpty)
              Positioned(
                top: 150, left: 40,
                child: AvatarJugadorWidget(
                  participante: rivales[0], esSuTurno: esTurnoDeRival(rivales[0].id),
                ),
              ),

            if (rivales.length > 1)
              Positioned(
                top: 80, left: 0, right: 0,
                child: Center(
                  child: AvatarJugadorWidget(
                    participante: rivales[1], esSuTurno: esTurnoDeRival(rivales[1].id),
                  ),
                ),
              ),

            if (rivales.length > 2)
              Positioned(
                top: 150, right: 40,
                child: AvatarJugadorWidget(
                  participante: rivales[2], esSuTurno: esTurnoDeRival(rivales[2].id),
                ),
              ),

            Center(
              child: MazoCentralWidget(
                cartaEnMesa: partida.currentCard != null ? Carta.fromJson(partida.currentCard) : null,
                onRobar: esMiTurno ? () => vm.robarCarta() : () {},
                cartasRestantes: partida.drawCount > 0 ? partida.drawCount : null,
              ),
            ),

            _buildTopBar(context, vm, partidaVm),

            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (esMiTurno)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        "¡TU TURNO!",
                        style: TextStyle(
                          color: Colors.yellowAccent,
                          fontWeight: FontWeight.bold, fontSize: 18,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                        ),
                      ),
                    ),
                  if (partidaVm.turnoExpiraEnMs != null && !partidaVm.partidaEstaPausada)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: _CountdownTurno(deadlineMs: partidaVm.turnoExpiraEnMs!),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: _buildManoJugador(miJugador, esMiTurno, vm),
                  ),
                ],
              ),
            ),

            Positioned(
              right: 16, bottom: 156,
              child: SafeArea(
                child: ChatPartidaWidget(
                  partidaId: partida.gameId, miUsuario: auth.usuario?.nombreUsuario ?? miId,
                ),
              ),
            ),

            const PanelHabilidadRol(),

            if (partidaVm.votanteActualPausa != null &&
                !partidaVm.yoHeVotadoPausa &&
                !partidaVm.partidaEstaPausada)
              Positioned(
                top: 90, left: 16, right: 16,
                child: _VotoBannerPausa(
                  votante: partidaVm.votanteActualPausa!,
                  onPausar: () {
                    partidaVm.aceptarPausa();
                  },
                  onNo: () => partidaVm.emitirRechazoPausa(),
                ),
              ),

            if (vm.mostrandoAjustes)
              Positioned.fill(child: AjustesOverlay(onClose: () => vm.cerrarAjustes())),

            if (partidaVm.partidaEstaPausada)
              _buildOverlayPartidaPausada(context, partidaVm),

            if (partida.phase == 'finished')
              _buildOverlayPartidaFinalizada(context, partidaVm, auth),
          ],
        ),
      ),
    );
  }

  Widget _buildManoJugador(JugadorPartidaModel? miJugador, bool esMiTurno, TableroViewModel vm) {
    final cartas = (miJugador?.hand ?? []).whereType<Map<String, dynamic>>().toList();
    if (cartas.isEmpty) return const SizedBox(height: 118);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: (cartas.length * 48 + 72).clamp(180, 900).toDouble(),
        height: 128,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            for (int i = 0; i < cartas.length; i++)
              Positioned(
                left: i * 48.0,
                bottom: 0,
                child: Builder(
                  builder: (context) {
                    final carta = Carta.fromJson(cartas[i]);
                    return Transform.rotate(
                      angle: (i - (cartas.length - 1) / 2) * 0.035,
                      alignment: Alignment.bottomCenter,
                      child: CartaWidget(
                        carta: carta, width: 78,
                        onTap: esMiTurno ? () => vm.intentarTirarCarta(carta.id) : null,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFondo() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage('assets/images/tableroFuturista.png'), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, TableroViewModel vm, PartidaActualViewModel partidaVm) {
    final totalJugadores = partidaVm.partidaActual?.jugadores.length ?? 0;

    final bool mostrarBotonPausa = !partidaVm.partidaEstaPausada &&
        !partidaVm.isVsIA &&
        partidaVm.partidaActual?.phase == 'playing' &&
        partidaVm.partidaActual?.isPrivate == true;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/images/logo.png', height: 40),
            const Text("0:00", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),

            if (mostrarBotonPausa)
              _AnimatedPauseButton(
                votosActuales: partidaVm.votosPausa,
                totalJugadores: totalJugadores,
                haVotado: partidaVm.yoHeVotadoPausa,
                onTap: () {
                  if (!partidaVm.yoHeVotadoPausa) {
                    partidaVm.solicitarPausa();
                  }
                },
              ),

            _AnimatedSettingsButton(onTap: () => vm.abrirAjustes()),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayPartidaPausada(BuildContext context, PartidaActualViewModel partidaVm) {
    final yaVote = partidaVm.yoHeVotadoReanudar;
    final voters = partidaVm.votersReanudar;
    final votos = partidaVm.votosReanudar;
    final totalNecesarios = partidaVm.partidaActual?.jugadores.where((j) => !j.isBot).length ?? 0;
    final progreso = totalNecesarios > 0 ? (votos / totalNecesarios).clamp(0.0, 1.0) : 0.0;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.75),
        child: Center(
          child: Container(
            width: 340,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1535),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 5)],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: yaVote
                  ? _PauseWaitingState(
                key: const ValueKey('post-vote'),
                voters: voters, votos: votos, total: totalNecesarios, progreso: progreso,
                onGoHome: () => _volverAlInicioDesdePausa(context, partidaVm),
              )
                  : _PausePreVoteState(
                key: const ValueKey('pre-vote'),
                voters: voters, votos: votos, total: totalNecesarios,
                onVote: () => partidaVm.emitirVotoReanudar(),
                onGoHome: () => _volverAlInicioDesdePausa(context, partidaVm),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayPartidaFinalizada(BuildContext context, PartidaActualViewModel partidaVm, AuthProvider auth) {
    final miUsuario = auth.usuario?.nombreUsuario;
    final yoGane = partidaVm.ganadorEs(miUsuario);

    if (partidaVm.recompensaPendienteAplicar && yoGane) {
      final monedasTotales = partidaVm.monedasTotalesUltimaPartida!;
      partidaVm.marcarRecompensaAplicada();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        auth.actualizarMonedas(monedasTotales);
      });
    }

    final tituloPrincipal = yoGane
        ? "¡Has ganado!"
        : partidaVm.ganadorEsBot
        ? "Ha ganado un bot"
        : (partidaVm.ganadorPartida != null ? "Ha ganado ${partidaVm.ganadorPartida}" : "Partida finalizada");

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.78),
        child: Center(
          child: Container(
            width: 330,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1535),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.5)),
              boxShadow: [BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.2), blurRadius: 24)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, color: Color(0xFFFFD54F), size: 42),
                const SizedBox(height: 14),
                Text(tituloPrincipal, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
                if (yoGane && partidaVm.recompensaUltimaPartida > 0) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD54F).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFD54F).withOpacity(0.6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.monetization_on, color: Color(0xFFFFD54F), size: 22),
                        const SizedBox(width: 8),
                        Text("+${partidaVm.recompensaUltimaPartida} monedas", style: const TextStyle(color: Color(0xFFFFD54F), fontWeight: FontWeight.w900, fontSize: 16)),
                      ],
                    ),
                  ),
                  if (partidaVm.monedasTotalesUltimaPartida != null) ...[
                    const SizedBox(height: 8),
                    Text("Saldo: ${partidaVm.monedasTotalesUltimaPartida}", style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.home, size: 18),
                    label: const Text("Volver al inicio", style: TextStyle(fontWeight: FontWeight.w900)),
                    onPressed: () {
                      partidaVm.abandonarYBorrarPartida();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _volverAlInicioDesdePausa(BuildContext context, PartidaActualViewModel partidaVm) {
    partidaVm.retirarVotoReanudar();
    partidaVm.limpiarPartida();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}


// =====================================================================
// OVERLAY DE PAUSA — pre-voto / post-voto
// =====================================================================
class _PausePreVoteState extends StatelessWidget {
  final List<String> voters;
  final int votos;
  final int total;
  final VoidCallback onVote;
  final VoidCallback onGoHome;

  const _PausePreVoteState({
    super.key, required this.voters, required this.votos, required this.total, required this.onVote, required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = votos > 0
        ? "¡Alguien quiere reanudar la partida!"
        : "¿Listo para continuar la partida?";

    final progreso = total > 0 ? (votos / total).clamp(0.0, 1.0) : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFF6482E4).withOpacity(0.2), shape: BoxShape.circle),
          child: const Icon(Icons.pause, color: Color(0xFF6482E4), size: 36),
        ),
        const SizedBox(height: 16),
        const Text("Partida Pausada", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13), textAlign: TextAlign.center),

        if (votos > 0) ...[
          const SizedBox(height: 16),
          Text("Votos para reanudar: ($votos/$total)", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progreso,
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF62B155)),
            ),
          ),
        ],

        if (voters.isNotEmpty) ...[const SizedBox(height: 14), _VoterChips(voters: voters)],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF62B155),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.play_arrow, size: 20),
            label: const Text("Quiero reanudar", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            onPressed: onVote,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.home, size: 18),
            label: const Text("Volver al inicio", style: TextStyle(fontWeight: FontWeight.w600)),
            onPressed: onGoHome,
          ),
        ),
        if(votos == 0) ... [
          const SizedBox(height: 14),
          Text("Se necesitan $total votos para reanudar", style: const TextStyle(color: Colors.white38, fontSize: 11), textAlign: TextAlign.center),
        ]
      ],
    );
  }
}

class _PauseWaitingState extends StatelessWidget {
  final List<String> voters;
  final int votos;
  final int total;
  final double progreso;
  final VoidCallback onGoHome;

  const _PauseWaitingState({
    super.key, required this.voters, required this.votos, required this.total, required this.progreso, required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _SpinningHourglass(),
        const SizedBox(height: 16),
        const Text("Esperando jugadores", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("$votos de $total jugador${total > 1 ? 'es' : ''} listos", style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progreso),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => LinearProgressIndicator(
              value: value, minHeight: 8, backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF62B155)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(total, (i) {
            final filled = i < votos;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300), margin: const EdgeInsets.symmetric(horizontal: 4),
              width: filled ? 12 : 10, height: filled ? 12 : 10,
              decoration: BoxDecoration(shape: BoxShape.circle, color: filled ? const Color(0xFF62B155) : Colors.white24),
            );
          }),
        ),
        if (voters.isNotEmpty) ...[const SizedBox(height: 14), _VoterChips(voters: voters)],
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.home, size: 18),
            label: const Text("Volver al inicio", style: TextStyle(fontWeight: FontWeight.w600)),
            onPressed: onGoHome,
          ),
        ),
        const SizedBox(height: 12),
        const Text("La partida se reanudará automáticamente cuando todos estén listos", style: TextStyle(color: Colors.white38, fontSize: 11), textAlign: TextAlign.center),
      ],
    );
  }
}

class _VoterChips extends StatelessWidget {
  final List<String> voters;
  const _VoterChips({required this.voters});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6, runSpacing: 6, alignment: WrapAlignment.center,
      children: voters.map((v) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF62B155).withOpacity(0.18),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF62B155).withOpacity(0.5)),
          ),
          child: Text("✓ $v", style: const TextStyle(color: Color(0xFFB7E7AC), fontWeight: FontWeight.w700, fontSize: 12)),
        );
      }).toList(),
    );
  }
}

class _SpinningHourglass extends StatefulWidget {
  const _SpinningHourglass();

  @override
  State<_SpinningHourglass> createState() => _SpinningHourglassState();
}

class _SpinningHourglassState extends State<_SpinningHourglass> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _ctrl,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFF6482E4).withOpacity(0.2), shape: BoxShape.circle),
        child: const Icon(Icons.hourglass_top, color: Color(0xFF6482E4), size: 36),
      ),
    );
  }
}

class _AnimatedSettingsButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AnimatedSettingsButton({required this.onTap});

  @override
  State<_AnimatedSettingsButton> createState() => _AnimatedSettingsButtonState();
}

class _AnimatedSettingsButtonState extends State<_AnimatedSettingsButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const neonCyan = Color(0xFF00FFFF);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        duration: Duration.zero,
        scale: _isPressed ? 1.2 : 1.0,
        child: AnimatedContainer(
          duration: Duration.zero,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isPressed ? neonCyan.withOpacity(0.1) : Colors.transparent,
            shape: BoxShape.circle,
            boxShadow: _isPressed ? [BoxShadow(color: neonCyan.withOpacity(0.7), blurRadius: 15, spreadRadius: 2)] : [],
          ),
          child: const Icon(Icons.menu, color: neonCyan, size: 36),
        ),
      ),
    );
  }
}

class _AnimatedPauseButton extends StatefulWidget {
  final int votosActuales;
  final int totalJugadores;
  final bool haVotado;
  final VoidCallback onTap;

  const _AnimatedPauseButton({
    required this.votosActuales, required this.totalJugadores, required this.haVotado, required this.onTap,
  });

  @override
  State<_AnimatedPauseButton> createState() => _AnimatedPauseButtonState();
}

class _AnimatedPauseButtonState extends State<_AnimatedPauseButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colorFondo = widget.haVotado ? Colors.grey.withOpacity(0.4) : const Color(0xFFD65B5B);
    final textBtn = widget.haVotado ? "ESPERANDO (${widget.votosActuales}/${widget.totalJugadores})" : "PAUSAR (${widget.votosActuales}/${widget.totalJugadores})";

    return GestureDetector(
      onTapDown: (_) { if (!widget.haVotado) setState(() => _isPressed = true); },
      onTapUp: (_) {
        if (!widget.haVotado) {
          setState(() => _isPressed = false);
          widget.onTap();
        }
      },
      onTapCancel: () { if (!widget.haVotado) setState(() => _isPressed = false); },
      child: AnimatedScale(
        duration: Duration.zero,
        scale: _isPressed ? 1.08 : 1.0,
        child: AnimatedContainer(
          duration: Duration.zero,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorFondo,
            borderRadius: BorderRadius.circular(12),
            border: widget.haVotado ? Border.all(color: Colors.white30) : null,
            boxShadow: _isPressed && !widget.haVotado ? [BoxShadow(color: const Color(0xFFD65B5B).withOpacity(0.7), blurRadius: 15, spreadRadius: 4)] : !widget.haVotado ? [const BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))] : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.haVotado ? Icons.hourglass_empty : Icons.pause, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(textBtn, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ),
    );
  }
}

class _VotoBannerPausa extends StatefulWidget {
  final String votante;
  final VoidCallback onPausar;
  final VoidCallback onNo;

  const _VotoBannerPausa({required this.votante, required this.onPausar, required this.onNo});

  @override
  State<_VotoBannerPausa> createState() => _VotoBannerPausaState();
}

class _VotoBannerPausaState extends State<_VotoBannerPausa> {
  static const _totalSeconds = 11;
  int _segundosRestantes = _totalSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // REGLA: El tiempo es controlado por Flutter. Si llega a 0, emite rechazo.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _segundosRestantes--);
      if (_segundosRestantes <= 0) {
        timer.cancel();
        widget.onNo();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _segundosRestantes / _totalSeconds;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2150),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 12, offset: Offset(0, 4))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.pause, color: Colors.blueAccent, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: widget.votante, style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 13)),
                        const TextSpan(text: ' quiere pausar la partida', style: TextStyle(color: Colors.white, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: progress, backgroundColor: Colors.white12, color: Colors.blueAccent, minHeight: 3),
                  ),
                  const SizedBox(height: 3),
                  Text('Se rechaza automáticamente en ${_segundosRestantes}s', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: widget.onPausar,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(color: const Color(0xFF4CAF50), borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, color: Colors.white, size: 13),
                    SizedBox(width: 4),
                    Text('Pausar', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: widget.onNo,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.close, color: Colors.white, size: 13),
                    SizedBox(width: 4),
                    Text('No', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownTurno extends StatefulWidget {
  final int deadlineMs;
  const _CountdownTurno({required this.deadlineMs});

  @override
  State<_CountdownTurno> createState() => _CountdownTurnoState();
}

class _CountdownTurnoState extends State<_CountdownTurno> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restanteMs = widget.deadlineMs - DateTime.now().millisecondsSinceEpoch;
    final segundos = (restanteMs / 1000).ceil().clamp(0, 99);

    Color color;
    if (segundos > 10) {
      color = const Color(0xFF53D86A);
    } else if (segundos > 5) {
      color = const Color(0xFFFFB300);
    } else {
      color = const Color(0xFFE53935);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.7), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, color: color, size: 14),
          const SizedBox(width: 6),
          Text("${segundos}s", style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13)),
        ],
      ),
    );
  }
}