import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/tablero_viewmodel.dart';
import '../viewmodels/partida_actual_viewmodel.dart';
import '../viewmodels/rol_viewmodel.dart';
import '../providers/auth_provider.dart';
import '../models/carta_model.dart';
import '../models/jugador_partida_model.dart';
import '../models/resultado_partida_model.dart';

import 'package:frontend_app/views/ajustes_overlay.dart';
import 'package:frontend_app/views/widgets/avatar_jugador_widget.dart';
import 'package:frontend_app/views/widgets/carta_widget.dart';
import 'package:frontend_app/views/widgets/chat_partida_widget.dart';
import 'package:frontend_app/views/widgets/mazo_central_widget.dart';
import 'package:frontend_app/views/widgets/rol_overlay.dart';
import 'package:frontend_app/views/widgets/pause_vote_banner.dart';

class TableroView extends StatelessWidget {
  const TableroView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TableroViewModel>();
    final partidaVm = context.watch<PartidaActualViewModel>();
    final rolVm = context.watch<RolViewModel>();
    final auth = context.watch<AuthProvider>();
    final partida = partidaVm.partidaActual;

    // Carga defensiva del rol cuando entramos al tablero con rolesMode=true.
    // El VM internamente es idempotente: si ya está cargado para este gameId
    // no vuelve a pedirlo. Usamos postFrameCallback para no llamar API durante
    // build.
    if (partida != null &&
        partida.rolesMode &&
        partida.phase == 'playing' &&
        !rolVm.cargando) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        rolVm.cargarMiRol(partida.gameId);
      });
    }
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

    // Identificar al jugador local. Damos prioridad al usuario autenticado
    // sobre partida.jugadorLocal por si algún flujo (ej. vs IA) no lo setea bien.
    final String miId = auth.usuario?.nombreUsuario ?? partida.jugadorLocal ?? '';
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

            // Posicionamos rivales "alrededor" del jugador local (que está abajo):
            //  1 rival  → arriba-centro
            //  2 rivales → izquierda + derecha (a media altura)
            //  3 rivales → izquierda + arriba-centro + derecha
            if (rivales.length == 1)
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: AvatarJugadorWidget(
                    participante: rivales[0],
                    esSuTurno: esTurnoDeRival(rivales[0].id),
                    estilo: estiloActivo,
                  ),
                ),
              ),

            if (rivales.length >= 2)
              Positioned(
                top: 180,
                left: 16,
                child: AvatarJugadorWidget(
                  participante: rivales[0],
                  esSuTurno: esTurnoDeRival(rivales[0].id),
                  estilo: estiloActivo,
                ),
              ),

            if (rivales.length == 3)
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

            if (rivales.length >= 2)
              Positioned(
                top: 180,
                right: 16,
                child: AvatarJugadorWidget(
                  participante:
                      rivales.length == 2 ? rivales[1] : rivales[2],
                  esSuTurno: esTurnoDeRival(
                      (rivales.length == 2 ? rivales[1] : rivales[2]).id),
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

            // Botón de Rol: visible sólo en partidas con rolesMode activo.
            // Encima del chat, lado derecho. Pulsar abre el overlay.
            if (partida.rolesMode)
              Positioned(
                right: 16,
                bottom: 90,
                child: SafeArea(
                  child: _RolFloatingButton(
                    rolVm: rolVm,
                    onTap: () => vm.abrirRol(),
                  ),
                ),
              ),

            // 3. OVERLAY DE AJUSTES
            if (vm.mostrandoAjustes)
              Positioned.fill(
                child: AjustesOverlay(onClose: () => vm.cerrarAjustes()),
              ),

            if (vm.mostrandoRol)
              RolOverlay(onClose: () => vm.cerrarRol()),

            // Banner de voto-pausa entrante: otro jugador propone pausar.
            // Aparece arriba del tablero, encima del top bar.
            if (partidaVm.solicitudPausaDe != null &&
                !partidaVm.partidaEstaPausada)
              Positioned(
                top: 70,
                left: 12,
                right: 12,
                child: SafeArea(
                  child: Center(
                    child: PauseVoteBanner(
                      solicitante: partidaVm.solicitudPausaDe!,
                      onVoteYes: () => partidaVm.confirmarVotoPausa(),
                      onVoteNo: () => partidaVm.rechazarVotoPausa(),
                      onDismiss: () => partidaVm.rechazarVotoPausa(),
                    ),
                  ),
                ),
              ),

            if (partidaVm.partidaEstaPausada)
              _buildOverlayPartidaPausada(context, partidaVm),

            // Loading defensivo: si el socket nos dijo "ya estás jugando"
            // pero la mano del jugador local aún no ha llegado, mostramos un
            // indicador mientras el VM hace polling al REST. Sólo se ve si
            // realmente falta mano — no aparece en la partida normal.
            if (partida.phase == 'playing' &&
                partidaVm.esperandoManoInicial &&
                (miJugador == null || miJugador.hand.isEmpty))
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.55),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            color: Color(0xFF00E5FF),
                            strokeWidth: 3,
                          ),
                        ),
                        SizedBox(height: 18),
                        Text(
                          'Cargando partida…',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Sincronizando tu mano con el servidor',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            if (partida.phase == 'finished') const _GameOverOverlay(),
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
    // El botón de pausa SOLO aparece en partidas privadas humano-vs-humano:
    // - excluido en públicas (no aplica)
    // - excluido en partidas con bots / vs IA (no tiene sentido)
    // - oculto si la partida YA está pausada
    final partida = partidaVm.partidaActual;
    final hayBots = partida?.jugadores.any((j) => j.isBot) ?? false;
    final bool mostrarBotonPausa = !partidaVm.partidaEstaPausada &&
        (partida?.isPrivate ?? false) &&
        !hayBots;

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
                  if (partidaVm.yoHeVotadoPausa) return;
                  partidaVm.emitirVotoPausa();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 3),
                      backgroundColor: const Color(0xFF0F1535),
                      behavior: SnackBarBehavior.floating,
                      content: const Text(
                        'Esperando que los demás voten pausar…',
                        style: TextStyle(
                          color: Color(0xFFFFD54F),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  );
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

}

// ============================================================================
// _GameOverOverlay
// ============================================================================
//
// Pantalla rica de fin de partida. Equivalente al GameOverScreen.jsx del web:
// muestra trofeo, recompensa propia destacada, lista de jugadores con sus
// monedas, botón "Volver al inicio". En initState dispara una sola vez la
// actualización de monedas / total_ganadas / total_partidas en AuthProvider.
// ============================================================================
class _GameOverOverlay extends StatefulWidget {
  const _GameOverOverlay();

  @override
  State<_GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<_GameOverOverlay> {
  bool _statsAplicadas = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _aplicarStatsUnaVez());
  }

  void _aplicarStatsUnaVez() {
    if (_statsAplicadas || !mounted) return;
    final partidaVm = context.read<PartidaActualViewModel>();
    final auth = context.read<AuthProvider>();
    final resultado = partidaVm.resultadoFinal;
    final yo = resultado?.resultadoDe(auth.usuario?.nombreUsuario);
    if (yo == null) return;
    auth.actualizarStatsPostPartida(
      monedas: yo.monedasTotales,
      totalGanadas: yo.totalGanadas,
      totalPartidas: yo.totalPartidas,
    );
    _statsAplicadas = true;
  }

  @override
  Widget build(BuildContext context) {
    final partidaVm = context.watch<PartidaActualViewModel>();
    final auth = context.watch<AuthProvider>();
    final resultado = partidaVm.resultadoFinal;
    final miId = auth.usuario?.nombreUsuario ?? partidaVm.partidaActual?.jugadorLocal ?? '';
    final yo = resultado?.resultadoDe(miId);

    final bool soyGanador = (resultado?.winner == miId) && miId.isNotEmpty;
    final int recompensaPropia = yo?.monedasGanadas ??
        (soyGanador
            ? (resultado?.recompensaGanador ?? 50)
            : (resultado?.recompensaPerdedor ?? 10));

    final jugadoresOrdenados = [...?resultado?.jugadores]
      ..sort((a, b) {
        if (a.isWinner == b.isWinner) return 0;
        return a.isWinner ? -1 : 1;
      });

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.78),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.85, end: 1.0),
            duration: const Duration(milliseconds: 380),
            curve: Curves.elasticOut,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Container(
              width: 340,
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1535),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: soyGanador
                      ? const Color(0xFFFFD54F).withOpacity(0.6)
                      : const Color(0xFF00E5FF).withOpacity(0.45),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (soyGanador
                            ? const Color(0xFFFFD54F)
                            : const Color(0xFF00E5FF))
                        .withOpacity(0.2),
                    blurRadius: 28,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutBack,
                    builder: (context, v, child) => Transform.rotate(
                      angle: (1 - v) * -0.4,
                      child: Transform.scale(scale: v, child: child),
                    ),
                    child: Text(
                      soyGanador ? '🏆' : '🎮',
                      style: const TextStyle(fontSize: 56),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    soyGanador ? '¡Victoria!' : '¡Fin de partida!',
                    style: TextStyle(
                      color: soyGanador
                          ? const Color(0xFFFFD54F)
                          : Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    soyGanador
                        ? '¡Has ganado la partida!'
                        : (resultado != null
                            ? '${resultado.winner} se ha llevado la victoria'
                            : 'Partida finalizada'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _RewardBox(
                    label: soyGanador
                        ? '🥇 Recompensa de victoria'
                        : '🎖️ Monedas por participar',
                    amount: recompensaPropia,
                    accent: soyGanador
                        ? const Color(0xFFFFD54F)
                        : const Color(0xFF00E5FF),
                  ),
                  if (jugadoresOrdenados.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ...List.generate(jugadoresOrdenados.length, (i) {
                      final j = jugadoresOrdenados[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _PlayerResultRow(
                          jugador: j,
                          esYo: j.id == miId,
                          delayMs: 120 * i,
                        ),
                      );
                    }),
                  ],
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
                        'Volver al inicio',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      onPressed: () {
                        partidaVm.abandonarYBorrarPartida();
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RewardBox extends StatelessWidget {
  final String label;
  final int amount;
  final Color accent;
  const _RewardBox({
    required this.label,
    required this.amount,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: amount),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text(
                  '+$v',
                  style: TextStyle(
                    color: accent,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerResultRow extends StatelessWidget {
  final ResultadoJugador jugador;
  final bool esYo;
  final int delayMs;
  const _PlayerResultRow({
    required this.jugador,
    required this.esYo,
    required this.delayMs,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 320 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset((1 - v) * 30, 0),
          child: child,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: jugador.isWinner
              ? const Color(0xFFFFD54F).withOpacity(0.12)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: jugador.isWinner
                ? const Color(0xFFFFD54F).withOpacity(0.5)
                : Colors.white12,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: jugador.isWinner
                  ? const Color(0xFFFFD54F)
                  : const Color(0xFF3A4288),
              child: Text(
                jugador.isWinner
                    ? '🏆'
                    : (jugador.id.isNotEmpty
                        ? jugador.id[0].toUpperCase()
                        : '?'),
                style: TextStyle(
                  color: jugador.isWinner ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          jugador.id,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (esYo) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'TÚ',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    jugador.isBot
                        ? '🤖 Bot'
                        : (jugador.isWinner ? '🥇 Ganador' : 'Participante'),
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                const Text('🪙', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '+${jugador.monedasGanadas}',
                  style: const TextStyle(
                    color: Color(0xFFFFD54F),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
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

// Botón flotante para abrir el overlay del rol. Muestra el contador de usos
// restantes y se ilumina cuando `canUseNow` es true (es mi turno y aún
// tengo usos). Si todavía no se cargó el rol, sale neutro (cyan tenue).
class _RolFloatingButton extends StatefulWidget {
  final RolViewModel rolVm;
  final VoidCallback onTap;

  const _RolFloatingButton({required this.rolVm, required this.onTap});

  @override
  State<_RolFloatingButton> createState() => _RolFloatingButtonState();
}

class _RolFloatingButtonState extends State<_RolFloatingButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final miRol = widget.rolVm.miRol;
    final activo = miRol?.canUseNow ?? false;
    final restantes = miRol?.remainingUses ?? 0;
    final max = miRol?.maxUses ?? miRol?.rol?.maxUsos ?? 0;
    final color = activo ? const Color(0xFFFFD54F) : const Color(0xFF00E5FF);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 80),
        scale: _pressed ? 0.9 : 1.0,
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.72),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(activo ? 0.55 : 0.25),
                blurRadius: activo ? 22 : 14,
                spreadRadius: activo ? 2 : 1,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.psychology, color: color, size: 26),
              if (miRol != null && max > 0)
                Positioned(
                  right: -3,
                  top: -3,
                  child: Container(
                    constraints:
                        const BoxConstraints(minWidth: 20, minHeight: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: restantes > 0
                          ? const Color(0xFFFFD54F)
                          : Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        '$restantes',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
