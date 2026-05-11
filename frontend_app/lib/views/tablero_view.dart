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

class TableroView extends StatefulWidget {
  const TableroView({super.key});

  @override
  State<TableroView> createState() => _TableroViewState();
}

class _TableroViewState extends State<TableroView> {
  @override
  void initState() {
    super.initState();
    // 🔥 DETERMINISMO: Forzamos que el menú de ajustes nazca cerrado siempre.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<TableroViewModel>().cerrarAjustes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TableroViewModel>();
    final partidaVm = context.watch<PartidaActualViewModel>();
    final auth = context.watch<AuthProvider>();
    final partida = partidaVm.partidaActual;

    // Pantalla de carga profesional si no hay partida
    if (partida == null || partida.jugadores.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF00E5FF)),
              SizedBox(height: 20),
              Text("Sincronizando tablero...", style: TextStyle(color: Colors.white70, letterSpacing: 1.2)),
            ],
          ),
        ),
      );
    }

    final String miId = auth.usuario?.nombreUsuario ?? partida.jugadorLocal ?? '';
    final JugadorPartidaModel? miJugador = partida.jugadores.where((p) => p.id == miId).firstOrNull;
    final List<JugadorPartidaModel> rivales = partida.jugadores.where((p) => p.id != miId).toList();
    final bool esMiTurno = partida.esMiTurno(miId);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && partidaVm.partidaActual != null) {
          partidaVm.abandonarYBorrarPartida();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            _buildFondo(),

            // --- RIVALES (Distribución según capturas) ---
            if (rivales.isNotEmpty)
              Positioned(top: 150, left: 40, child: AvatarJugadorWidget(participante: rivales[0], esSuTurno: partida.currentTurn == rivales[0].id)),
            if (rivales.length > 1)
              Positioned(top: 60, left: 0, right: 0, child: Center(child: AvatarJugadorWidget(participante: rivales[1], esSuTurno: partida.currentTurn == rivales[1].id))),
            if (rivales.length > 2)
              Positioned(top: 150, right: MediaQuery.of(context).size.width * 0.35, child: AvatarJugadorWidget(participante: rivales[2], esSuTurno: partida.currentTurn == rivales[2].id)),

            // --- MESA CENTRAL ---
            Center(
              child: MazoCentralWidget(
                cartaEnMesa: partida.currentCard != null ? Carta.fromJson(partida.currentCard) : null,
                onRobar: esMiTurno ? () => partidaVm.robarCarta() : () {},
                cartasRestantes: partida.drawCount,
              ),
            ),

            // --- INFO SUPERIOR (Timer centrado) ---
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
                        child: Text(partidaVm.tiempoFormateado, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                      ),
                      const SizedBox(width: 15),
                      if (!partidaVm.partidaEstaPausada && !partidaVm.isVsIA && partidaVm.partidaActual?.isPrivate == true)
                        _AnimatedPauseButton(
                          votosActuales: partidaVm.votosPausa,
                          totalJugadores: partidaVm.partidaActual?.jugadores.length ?? 0,
                          haVotado: partidaVm.yoHeVotadoPausa,
                          onTap: () => partidaVm.solicitarPausa(),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // 🔥 COLUMNA DERECHA (ESTILO WEB: Ajustes -> Chat -> Roles)
            Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _AnimatedSettingsButton(onTap: () => vm.abrirAjustes()),
                    const SizedBox(height: 12),
                    _ChatButton(partidaId: partida.gameId, miId: miId),
                    if (partida.rolesMode) ...[
                      const SizedBox(height: 25),
                      _PanelRolWeb(vm: partidaVm),
                    ],
                  ],
                ),
              ),
            ),

            // --- MI MANO Y TURNO ---
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (esMiTurno)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6.0),
                      child: Text("¡TU TURNO!", style: TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold, fontSize: 18, shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
                    ),
                  if (partidaVm.turnoExpiraEnMs != null && !partidaVm.partidaEstaPausada)
                    Padding(padding: const EdgeInsets.only(bottom: 8.0), child: _CountdownTurno(deadlineMs: partidaVm.turnoExpiraEnMs!)),
                  Padding(padding: const EdgeInsets.only(bottom: 25), child: _buildManoJugador(miJugador, esMiTurno, vm, partidaVm)),
                ],
              ),
            ),

            // --- OVERLAYS ---
            if (partidaVm.votanteActualPausa != null && !partidaVm.yoHeVotadoPausa && !partidaVm.partidaEstaPausada)
              Positioned(top: 90, left: 16, right: 16, child: _VotoBannerPausa(votante: partidaVm.votanteActualPausa!, onPausar: () => partidaVm.aceptarPausa(), onNo: () => partidaVm.emitirRechazoPausa())),
            if (vm.mostrandoAjustes) Positioned.fill(child: AjustesOverlay(onClose: () => vm.cerrarAjustes())),
            if (partidaVm.partidaEstaPausada) _buildOverlayPartidaPausada(context, partidaVm),
            if (partida.phase == 'finished') _buildOverlayPartidaFinalizada(context, partidaVm, auth),
          ],
        ),
      ),
    );
  }

  Widget _buildManoJugador(JugadorPartidaModel? miJugador, bool esMiTurno, TableroViewModel vm, PartidaActualViewModel pVm) {
    final cartas = (miJugador?.hand ?? []).whereType<Map<String, dynamic>>().toList();
    if (cartas.isEmpty) {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD65B5B), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
        onPressed: () => pVm.cargarMiRol(),
        icon: const Icon(Icons.refresh, color: Colors.white),
        label: const Text("RECARGAR MANO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: (cartas.length * 36 + 75).clamp(180, 1000).toDouble(),
        height: 130,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            for (int i = 0; i < cartas.length; i++)
              Positioned(
                left: i * 36.0,
                bottom: 5,
                child: Builder(builder: (context) {
                  final carta = Carta.fromJson(cartas[i]);
                  return Transform.rotate(
                    angle: (i - (cartas.length - 1) / 2) * 0.032,
                    alignment: Alignment.bottomCenter,
                    child: CartaWidget(carta: carta, width: 80, onTap: esMiTurno ? () => vm.intentarTirarCarta(carta.id) : null),
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFondo() => Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/tableroFuturista.png'), fit: BoxFit.cover)));

  Widget _buildOverlayPartidaPausada(BuildContext context, PartidaActualViewModel partidaVm) {
    final total = partidaVm.partidaActual?.jugadores.where((j) => !j.isBot).length ?? 0;
    final progreso = total > 0 ? (partidaVm.votosReanudar / total).clamp(0.0, 1.0) : 0.0;
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: Container(
            width: 320, padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFF0F1535), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF00FFFF).withOpacity(0.5))),
            child: partidaVm.yoHeVotadoReanudar
                ? _PauseWaitingState(voters: partidaVm.votersReanudar, votos: partidaVm.votosReanudar, total: total, progreso: progreso, onGoHome: () => _volverAlInicioDesdePausa(context, partidaVm))
                : _PausePreVoteState(voters: partidaVm.votersReanudar, votos: partidaVm.votosReanudar, total: total, onVote: () => partidaVm.emitirVotoReanudar(), onGoHome: () => _volverAlInicioDesdePausa(context, partidaVm)),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayPartidaFinalizada(BuildContext context, PartidaActualViewModel partidaVm, AuthProvider auth) {
    final yoGane = partidaVm.ganadorEs(auth.usuario?.nombreUsuario);
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.9),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events, color: yoGane ? Colors.amber : Colors.grey, size: 80),
              const SizedBox(height: 20),
              Text(yoGane ? "¡VICTORIA!" : "PARTIDA FINALIZADA", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text("Ganador: ${partidaVm.ganadorPartida}", style: const TextStyle(color: Colors.white70, fontSize: 18)),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () {
                  partidaVm.abandonarYBorrarPartida();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text("VOLVER AL MENÚ", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
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
// 🔥 WIDGETS PRIVADOS (ESTILO WEB IMG_6603)
// =====================================================================

class _PanelRolWeb extends StatelessWidget {
  final PartidaActualViewModel vm;
  const _PanelRolWeb({required this.vm});

  @override
  Widget build(BuildContext context) {
    final rolName = vm.miRol?['nombre'] ?? 'Cargando...';
    final int maxUsos = vm.maxUsosRol;
    final int usosRestantes = (maxUsos - vm.usosRol).clamp(0, 99);
    final bool canUse = vm.canUseRoleNow && (vm.partidaActual?.esMiTurno(vm.partidaActual?.jugadorLocal ?? '') ?? false);

    return Container(
      width: 155,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1535).withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.4), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.masks, color: Color(0xFF00E5FF), size: 32),
          const SizedBox(height: 8),
          Text(rolName.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
          const Divider(color: Colors.white24, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _info("USOS", "$usosRestantes/$maxUsos"),
              _info("ESTADO", canUse ? "LISTO" : "ESPERA", color: canUse ? Colors.greenAccent : Colors.redAccent),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: canUse ? const Color(0xFF00E5FF) : Colors.white10, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
              onPressed: canUse ? () => _abrirHabilidad(context) : null,
              child: const Text("USAR ROL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
            ),
          )
        ],
      ),
    );
  }

  Widget _info(String l, String v, {Color color = Colors.white}) => Column(children: [Text(l, style: const TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)), const SizedBox(height: 2), Text(v, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900))]);

  void _abrirHabilidad(BuildContext context) {
    showGeneralDialog(
      context: context, barrierDismissible: true, barrierLabel: "Cerrar", barrierColor: Colors.black54,
      pageBuilder: (context, _, __) => Align(alignment: Alignment.centerRight, child: Material(color: Colors.transparent, child: Container(width: 280, margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 16), child: const PanelHabilidadRol()))),
    );
  }
}

class _ChatButton extends StatelessWidget {
  final String partidaId; final String miId;
  const _ChatButton({required this.partidaId, required this.miId});
  @override Widget build(BuildContext context) => Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(12), onTap: () { showDialog(context: context, builder: (context) => Dialog(backgroundColor: Colors.transparent, insetPadding: const EdgeInsets.all(16), child: Container(width: 350, height: 450, decoration: BoxDecoration(color: const Color(0xFF0F1535).withOpacity(0.95), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF00FFFF).withOpacity(0.5))), child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Scaffold(backgroundColor: Colors.transparent, body: ChatPartidaWidget(partidaId: partidaId, miUsuario: miId)))))); }, child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF0F1535).withOpacity(0.8), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF00FFFF).withOpacity(0.5))), child: const Icon(Icons.chat_bubble, color: Color(0xFF00FFFF), size: 24))));
}

class _AnimatedSettingsButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AnimatedSettingsButton({required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF0F1535).withOpacity(0.8), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF00FFFF).withOpacity(0.5))), child: const Icon(Icons.menu, color: Color(0xFF00FFFF), size: 24)));
}

class _AnimatedPauseButton extends StatefulWidget {
  final int votosActuales; final int totalJugadores; final bool haVotado; final VoidCallback onTap;
  const _AnimatedPauseButton({super.key, required this.votosActuales, required this.totalJugadores, required this.haVotado, required this.onTap});
  @override State<_AnimatedPauseButton> createState() => _AnimatedPauseButtonState();
}

class _AnimatedPauseButtonState extends State<_AnimatedPauseButton> {
  bool _isPressed = false;
  @override Widget build(BuildContext context) {
    final colorFondo = widget.haVotado ? Colors.grey.withOpacity(0.4) : const Color(0xFFD65B5B);
    final textBtn = widget.haVotado ? "ESPERANDO (${widget.votosActuales}/${widget.totalJugadores})" : "PAUSAR (${widget.votosActuales}/${widget.totalJugadores})";
    return GestureDetector(
        onTapDown: (_) { if (!widget.haVotado) setState(() => _isPressed = true); },
        onTapUp: (_) { if (!widget.haVotado) { setState(() => _isPressed = false); widget.onTap(); } },
        onTapCancel: () { if (!widget.haVotado) setState(() => _isPressed = false); },
        child: AnimatedScale(duration: const Duration(milliseconds: 100), scale: _isPressed ? 1.1 : 1.0, child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: colorFondo, borderRadius: BorderRadius.circular(12), border: widget.haVotado ? Border.all(color: Colors.white30) : null), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(widget.haVotado ? Icons.hourglass_empty : Icons.pause, color: Colors.white, size: 16), const SizedBox(width: 8), Text(textBtn, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900))]))));
  }
}

class _PausePreVoteState extends StatelessWidget {
  final List<String> voters; final int votos; final int total; final VoidCallback onVote; final VoidCallback onGoHome;
  const _PausePreVoteState({required this.voters, required this.votos, required this.total, required this.onVote, required this.onGoHome});
  @override Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.pause_circle_filled, color: Color(0xFF00FFFF), size: 50), const SizedBox(height: 16), const Text("PARTIDA PAUSADA", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 20), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 45), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: onVote, child: const Text("QUIERO REANUDAR", style: TextStyle(fontWeight: FontWeight.bold))), TextButton(onPressed: onGoHome, child: const Text("SALIR AL MENÚ", style: TextStyle(color: Colors.white54)))]);
}

class _PauseWaitingState extends StatelessWidget {
  final List<String> voters; final int votos; final int total; final double progreso; final VoidCallback onGoHome;
  const _PauseWaitingState({required this.voters, required this.votos, required this.total, required this.progreso, required this.onGoHome});
  @override Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [const CircularProgressIndicator(color: Color(0xFF00E5FF)), const SizedBox(height: 20), Text("ESPERANDO JUGADORES ($votos/$total)", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), const SizedBox(height: 10), ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progreso, backgroundColor: Colors.white10, color: Colors.green, minHeight: 8)), TextButton(onPressed: onGoHome, child: const Text("ABANDONAR", style: TextStyle(color: Colors.redAccent)))]);
}

class _VotoBannerPausa extends StatefulWidget {
  final String votante; final VoidCallback onPausar; final VoidCallback onNo;
  const _VotoBannerPausa({required this.votante, required this.onPausar, required this.onNo});
  @override State<_VotoBannerPausa> createState() => _VotoBannerPausaState();
}

class _VotoBannerPausaState extends State<_VotoBannerPausa> {
  int _s = 11; Timer? _t;
  @override void initState() { super.initState(); _t = Timer.periodic(const Duration(seconds: 1), (t) { if (!mounted) return; setState(() => _s--); if (_s <= 0) { t.cancel(); widget.onNo(); } }); }
  @override void dispose() { _t?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context) => Material(color: Colors.transparent, child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: const Color(0xFF1A2150), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white12)), child: Row(children: [const Icon(Icons.pause, color: Colors.blueAccent, size: 24), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${widget.votante} quiere pausar', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), const SizedBox(height: 4), ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: _s / 11, minHeight: 3, color: Colors.blueAccent))])), const SizedBox(width: 12), IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: widget.onPausar), IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: widget.onNo)])));
}

class _CountdownTurno extends StatefulWidget {
  final int deadlineMs; const _CountdownTurno({required this.deadlineMs});
  @override State<_CountdownTurno> createState() => _CountdownTurnoState();
}

class _CountdownTurnoState extends State<_CountdownTurno> {
  Timer? _t;
  @override void initState() { super.initState(); _t = Timer.periodic(const Duration(milliseconds: 500), (_) { if (mounted) setState(() {}); }); }
  @override void dispose() { _t?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final s = ((widget.deadlineMs - DateTime.now().millisecondsSinceEpoch) / 1000).ceil().clamp(0, 99);
    Color c = s > 10 ? const Color(0xFF53D86A) : (s > 5 ? Colors.orange : Colors.red);
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10), border: Border.all(color: c)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.timer, color: c, size: 14), const SizedBox(width: 6), Text("${s}s", style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 13))]));
  }
}