import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/partida_actual_viewmodel.dart';
import 'tablero_view.dart';

class SalaEsperaView extends StatefulWidget {
  final String modoJuego;

  const SalaEsperaView({super.key, required this.modoJuego});

  @override
  State<SalaEsperaView> createState() => _SalaEsperaViewState();
}

class _SalaEsperaViewState extends State<SalaEsperaView> {
  bool _navegandoATablero = false;
  bool _navegandoAlMenu = false;

  Future<bool> _pedirConfirmacionSalir(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF3A4288),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
            SizedBox(width: 10),
            Text('¿Abandonar sala?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
          'Si sales ahora, la sala se cerrará y la partida se cancelará para todos. ¿Estás seguro?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Devuelve false
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935), // Rojo peligro
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true), // Devuelve true
            child: const Text('Sí, salir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final partidaVm = context.watch<PartidaActualViewModel>();
    final partida = partidaVm.partidaActual;

    final codigo = partida?.code ?? "---";
    final jugadores = partida?.jugadores ?? [];
    final maxJugadores = partidaVm.maxJugadores;

    final porcentaje = maxJugadores > 0
        ? (jugadores.length / maxJugadores).clamp(0.0, 1.0)
        : 0.0;

    final phase = partida?.phase ?? 'waiting';
    final yoSoyHost = partidaVm.yoSoyHost;

    if (phase == 'playing' && !_navegandoATablero) {
      _navegandoATablero = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TableroView()),
        );
      });
    }

    // El host cerró la sala → echamos a este jugador al menú
    if (partidaVm.partidaEliminada && !_navegandoAlMenu) {
      _navegandoAlMenu = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        partidaVm.limpiarPartida();
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
      });
    }

    const bg = Color(0xFF2D3473);
    const panel = Color(0xFF3A4288);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (!yoSoyHost) return; // Joiners no pueden salir de la sala

        final salir = await _pedirConfirmacionSalir(context);
        if (salir) {
          await partidaVm.abandonarYBorrarPartida();
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
            backgroundColor: bg,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: panel,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (yoSoyHost)
                              _AnimatedExitPill(
                                onTap: () async {
                                  final salir = await _pedirConfirmacionSalir(context);
                                  if (salir) {
                                    await partidaVm.abandonarYBorrarPartida();
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  }
                                },
                              )
                            else
                              const SizedBox.shrink(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text("CÓDIGO DE SALA",
                                    style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
                                Text(codigo,
                                    style: const TextStyle(color: Color(0xFF53D86A), fontSize: 18, fontWeight: FontWeight.w900)),
                              ],
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 6),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Row(
                          children: [
                            const Icon(Icons.bolt, color: Colors.orangeAccent, size: 24),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Sala de Espera",
                                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                                  Text(widget.modoJuego,
                                      style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Jugadores: ${jugadores.length}/$maxJugadores",
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                                Text("${(porcentaje * 100).toInt()}%",
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                              ],
                            ),
                            const SizedBox(height: 5),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: porcentaje,
                                backgroundColor: Colors.white10,
                                color: const Color(0xFF53D86A),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final esLandscape = constraints.maxWidth > 600;
                              final crossAxisCount = esLandscape ? 4 : 2;
                              final aspectRatio = esLandscape ? 3.2 : 2.4;
                              return GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: aspectRatio,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                itemCount: maxJugadores,
                                itemBuilder: (context, index) {
                                  if (index < jugadores.length) {
                                    final j = jugadores[index];
                                    final esYo = j.id == partida?.jugadorLocal;
                                    // Nombre real del backend (id = nombre de
                                    // usuario para humanos, "Bot_NNNN" para bots).
                                    // Si es el local, marcamos "(Tú)" para distinguir.
                                    final nombre = esYo ? "${j.id} (Tú)" : j.id;
                                    final letra = j.id.isNotEmpty
                                        ? j.id[0].toUpperCase()
                                        : '?';
                                    return _buildPlayerCard(
                                      nombre: nombre,
                                      status: "LISTO",
                                      esHost: index == 0,
                                      letra: letra,
                                    );
                                  }
                                  return _buildEmptyCard();
                                },
                              );
                            },
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                        child: _buildBotonComenzar(context, partidaVm),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildPlayerCard({required String nombre, required String status, bool esHost = false, required String letra}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2A316B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: esHost ? const Color(0xFF53D86A).withOpacity(0.5) : Colors.white10,
            width: 1.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF3A4288),
              child: Text(letra, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(nombre, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                    ),
                    if (esHost)
                      const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.emoji_events, color: Colors.orange, size: 12)),
                  ],
                ),
                Text(status, style: const TextStyle(color: Color(0xFF53D86A), fontSize: 10, fontWeight: FontWeight.w900)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10, style: BorderStyle.solid),
      ),
      child: const Center(
          child: Text("Esperando jugador...",
              style: TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.w600))),
    );
  }

  Widget _buildBotonComenzar(BuildContext context, PartidaActualViewModel vm) {
    final yoSoyHost = vm.yoSoyHost;
    final hayMinimoJugadores = (vm.partidaActual?.jugadores.length ?? 0) >= 2;

    // Solo el host puede iniciar la partida.
    if (!yoSoyHost) {
      return Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF2A316B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: const Center(
          child: Text(
            "Esperando a que el anfitrión inicie la partida...",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    final bool canStart = hayMinimoJugadores;

    return GestureDetector(
      onTap: canStart
          ? () {
              vm.iniciarPartida(vsIA: false, cantidadBots: 0);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Iniciando partida, esperando al servidor...'),
                ),
              );
            }
          : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: canStart ? 1.0 : 0.5,
        child: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
              color: const Color(0xFF53D86A),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: const Color(0xFF53D86A).withOpacity(0.3), blurRadius: 8, spreadRadius: 1)
              ]),
          child: const Center(
              child: Text("Comenzar partida",
                  style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w900))),
        ),
      ),
    );
  }
}

class _AnimatedExitPill extends StatefulWidget {
  final VoidCallback onTap;
  const _AnimatedExitPill({required this.onTap});

  @override
  State<_AnimatedExitPill> createState() => _AnimatedExitPillState();
}

class _AnimatedExitPillState extends State<_AnimatedExitPill> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const activeBlue = Color(0xFF3A6BFF);
    const idleColor = Color(0xFF1E244D);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        duration: Duration.zero,
        scale: _isPressed ? 1.08 : 1.0,
        child: AnimatedContainer(
          duration: Duration.zero,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _isPressed ? activeBlue : idleColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isPressed
                ? [BoxShadow(color: activeBlue.withOpacity(0.7), blurRadius: 15, spreadRadius: 4)]
                : [],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Salir', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}