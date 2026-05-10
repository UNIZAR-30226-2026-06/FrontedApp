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

class TableroView extends StatelessWidget {
  const TableroView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TableroViewModel>();
    final partidaVm = context.watch<PartidaActualViewModel>();
    final auth = context.watch<AuthProvider>();
    final partida = partidaVm.partidaActual;
    final estiloActivo = estiloCartaDesdeDatos(
      id: auth.usuario?.idEstiloSeleccionado,
      nombre: auth.usuario?.estiloNombre,
      image: auth.usuario?.estiloImage,
    );

    if (partida == null || partida.jugadores.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00FFFF)),
        ),
      );
    }

    // Identificar al jugador local y a los rivales
    final String miId = partida.jugadorLocal ?? '';
    final JugadorPartidaModel? miJugador = partida.jugadores
        .where((p) => p.id == miId)
        .firstOrNull;

    final List<JugadorPartidaModel> rivales = partida.jugadores
        .where((p) => p.id != miId)
        .toList();

    final bool esMiTurno = partida.esMiTurno(miId);

    bool esTurnoDeRival(String rivalId) {
      if (partida.jugadores.isEmpty) return false;
      return partida
              .jugadores[partida.currentTurn % partida.jugadores.length]
              .id ==
          rivalId;
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
            // 1. EL FONDO INTACTO
            _buildFondo(),

            if (rivales.isNotEmpty)
              Positioned(
                top: 150,
                left: 40,
                child: AvatarJugadorWidget(
                  participante: rivales[0],
                  esSuTurno: esTurnoDeRival(rivales[0].id),
                  estilo: estiloActivo,
                ),
              ),

            if (rivales.length > 1)
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: AvatarJugadorWidget(
                    participante: rivales[1],
                    esSuTurno: esTurnoDeRival(rivales[1].id),
                    estilo: estiloActivo,
                  ),
                ),
              ),

            if (rivales.length > 2)
              Positioned(
                top: 150,
                right: 40,
                child: AvatarJugadorWidget(
                  participante: rivales[2],
                  esSuTurno: esTurnoDeRival(rivales[2].id),
                  estilo: estiloActivo,
                ),
              ),

            // Mazo central
            Center(
              child: MazoCentralWidget(
                cartaEnMesa: partida.currentCard != null
                    ? Carta.fromJson(partida.currentCard)
                    : null,
                onRobar: esMiTurno ? () => vm.robarCarta() : () {},
                estilo: estiloActivo,
              ),
            ),

            // 2. TOP BAR ACTUALIZADA (Ahora recibe el ViewModel de la partida)
            _buildTopBar(context, vm, partidaVm),

            // Mano del jugador local
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (esMiTurno)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        "¡TU TURNO!",
                        style: TextStyle(
                          color: Colors.yellowAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: _buildManoJugador(
                      miJugador,
                      esMiTurno,
                      vm,
                      estiloActivo,
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              right: 16,
              bottom: 22,
              child: SafeArea(
                child: ChatPartidaWidget(
                  partidaId: partida.gameId,
                  miUsuario: auth.usuario?.nombreUsuario ?? miId,
                ),
              ),
            ),

            // 3. OVERLAY DE AJUSTES
            if (vm.mostrandoAjustes)
              Positioned.fill(
                child: AjustesOverlay(onClose: () => vm.cerrarAjustes()),
              ),

            if (partidaVm.partidaEstaPausada)
              _buildOverlayPartidaPausada(context, partidaVm),

            if (partida.phase == 'finished')
              _buildOverlayPartidaFinalizada(context, partidaVm),
          ],
        ),
      ),
    );
  }

  Widget _buildManoJugador(
    JugadorPartidaModel? miJugador,
    bool esMiTurno,
    TableroViewModel vm,
    EstiloCarta estilo,
  ) {
    final cartas = (miJugador?.hand ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();
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
                left: i * 48,
                bottom: 0,
                child: Builder(
                  builder: (context) {
                    final carta = Carta.fromJson(cartas[i]);
                    return Transform.rotate(
                      angle: (i - (cartas.length - 1) / 2) * 0.035,
                      alignment: Alignment.bottomCenter,
                      child: CartaWidget(
                        carta: carta,
                        width: 78,
                        estilo: estilo,
                        onTap: esMiTurno
                            ? () => vm.intentarTirarCarta(carta.id)
                            : null,
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
        image: DecorationImage(
          image: AssetImage('assets/images/tableroFuturista.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // --- TOP BAR REFATORIZADA ---
  Widget _buildTopBar(
    BuildContext context,
    TableroViewModel vm,
    PartidaActualViewModel partidaVm,
  ) {
    final totalJugadores = partidaVm.partidaActual?.jugadores.length ?? 0;

    // Ocultamos el botón de la barra superior si la partida ya está pausada
    final bool mostrarBotonPausa = !partidaVm.partidaEstaPausada;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/images/logo.png', height: 40),
            const Text(
              "0:00",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),

            if (mostrarBotonPausa)
              _AnimatedPauseButton(
                votosActuales: partidaVm.votosPausa,
                totalJugadores: totalJugadores,
                haVotado: partidaVm.yoHeVotadoPausa,
                onTap: () {
                  if (!partidaVm.yoHeVotadoPausa) {
                    partidaVm.emitirVotoPausa();
                    debugPrint("Votando para pausar...");
                  }
                },
              ),

            _AnimatedSettingsButton(onTap: () => vm.abrirAjustes()),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayPartidaPausada(
    BuildContext context,
    PartidaActualViewModel partidaVm,
  ) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.75), // Fondo oscurecido
        child: Center(
          child: Container(
            width: 340,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(
                0xFF0F1535,
              ), // Color azul oscuro similar al diseño web
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6482E4).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.pause,
                    color: Color(0xFF6482E4),
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Partida Pausada",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "La partida ha sido pausada por consenso",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // BOTÓN REANUDAR DINÁMICO
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      // Si ya he votado, lo ponemos gris. Si no, verde.
                      backgroundColor: partidaVm.yoHeVotadoReanudar
                          ? Colors.grey.withOpacity(0.5)
                          : const Color(0xFF81C784),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(
                      partidaVm.yoHeVotadoReanudar
                          ? Icons.hourglass_top
                          : Icons.play_arrow,
                      size: 20,
                    ),
                    label: Text(
                      partidaVm.yoHeVotadoReanudar
                          ? "ESPERANDO (${partidaVm.votosReanudar}/${partidaVm.partidaActual?.jugadores.length ?? 4})"
                          : "Votar para reanudar",
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    onPressed: () {
                      if (!partidaVm.yoHeVotadoReanudar) {
                        partidaVm.emitirVotoReanudar();
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // BOTÓN VOLVER AL INICIO
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.home, size: 18),
                    label: const Text(
                      "Volver al inicio",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onPressed: () {
                      partidaVm.abandonarYBorrarPartida();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Puedes retomar la partida desde Partidas Pausadas en el menú principal",
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayPartidaFinalizada(
    BuildContext context,
    PartidaActualViewModel partidaVm,
  ) {
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
              border: Border.all(
                color: const Color(0xFF00E5FF).withOpacity(0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withOpacity(0.2),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.emoji_events,
                  color: Color(0xFFFFD54F),
                  size: 42,
                ),
                const SizedBox(height: 14),
                Text(
                  partidaVm.error ?? "Partida finalizada",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.home, size: 18),
                    label: const Text(
                      "Volver al inicio",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
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
}

// ... (El _AnimatedSettingsButton sigue exactamente igual) ...
class _AnimatedSettingsButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AnimatedSettingsButton({required this.onTap});

  @override
  State<_AnimatedSettingsButton> createState() =>
      _AnimatedSettingsButtonState();
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
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: neonCyan.withOpacity(0.7),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: const Icon(Icons.menu, color: neonCyan, size: 36),
        ),
      ),
    );
  }
}

// --- BOTÓN DE PAUSA DINÁMICO ---
class _AnimatedPauseButton extends StatefulWidget {
  final int votosActuales;
  final int totalJugadores;
  final bool haVotado;
  final VoidCallback onTap;

  const _AnimatedPauseButton({
    required this.votosActuales,
    required this.totalJugadores,
    required this.haVotado,
    required this.onTap,
  });

  @override
  State<_AnimatedPauseButton> createState() => _AnimatedPauseButtonState();
}

class _AnimatedPauseButtonState extends State<_AnimatedPauseButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Si ya ha votado, el botón se pone grisáceo transparente. Si no, mantiene tu rojo original.
    final colorFondo = widget.haVotado
        ? Colors.grey.withOpacity(0.4)
        : const Color(0xFFD65B5B);
    final textBtn = widget.haVotado
        ? "ESPERANDO (${widget.votosActuales}/${widget.totalJugadores})"
        : "PAUSAR (${widget.votosActuales}/${widget.totalJugadores})";

    return GestureDetector(
      onTapDown: (_) {
        if (!widget.haVotado) setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        if (!widget.haVotado) {
          setState(() => _isPressed = false);
          widget.onTap();
        }
      },
      onTapCancel: () {
        if (!widget.haVotado) setState(() => _isPressed = false);
      },
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
            boxShadow: _isPressed && !widget.haVotado
                ? [
                    BoxShadow(
                      color: const Color(0xFFD65B5B).withOpacity(0.7),
                      blurRadius: 15,
                      spreadRadius: 4,
                    ),
                  ]
                : !widget.haVotado
                ? [
                    const BoxShadow(
                      color: Colors.black45,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.haVotado ? Icons.hourglass_empty : Icons.pause,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                textBtn,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
