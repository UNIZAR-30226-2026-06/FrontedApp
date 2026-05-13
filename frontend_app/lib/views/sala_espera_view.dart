import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/partida_actual_viewmodel.dart';
import 'tablero_view.dart';

class SalaEsperaView extends StatelessWidget {
  final String modoJuego;

  /// Si es `true`, sólo se puede iniciar cuando la sala está completa
  /// (`jugadores.length == maxJugadores`). Si es `false`, basta con ≥2
  /// jugadores. Default `false` para no alterar el flujo de personalizadas
  /// y partidas vs IA.
  final bool requiereSalaLlena;

  const SalaEsperaView({
    super.key,
    required this.modoJuego,
    this.requiereSalaLlena = false,
  });

  // 🔥 NUEVA FUNCIÓN: Muestra el popup de confirmación
  Future<bool> _pedirConfirmacionSalir(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Obliga a elegir una opción
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
    ) ?? false; // Si tocan fuera por algún motivo, devuelve false
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // 🔥 Al darle al botón físico de "Atrás", pedimos confirmación
        final salir = await _pedirConfirmacionSalir(context);
        if (salir) {
          await partidaVm.abandonarYBorrarPartida();
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Selector<PartidaActualViewModel, String>(
        selector: (context, vm) => vm.partidaActual?.phase ?? 'waiting',
        builder: (context, phase, child) {

          if (phase == 'playing') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const TableroView()),
              );
            });
          }

          const bg = Color(0xFF2D3473);
          const panel = Color(0xFF3A4288);

          return Scaffold(
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
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _AnimatedExitPill(
                              onTap: () async {
                                // 🔥 Al darle al botón "Salir" de la UI, pedimos confirmación
                                final salir = await _pedirConfirmacionSalir(context);
                                if (salir) {
                                  await partidaVm.abandonarYBorrarPartida();
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                }
                              },
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text("CÓDIGO DE SALA",
                                    style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                                Text(codigo,
                                    style: const TextStyle(color: Color(0xFF53D86A), fontSize: 22, fontWeight: FontWeight.w900)),
                              ],
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Row(
                          children: [
                            const Icon(Icons.bolt, color: Colors.orangeAccent, size: 36),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Sala de Espera",
                                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                                Text(modoJuego,
                                    style: const TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Jugadores: ${jugadores.length}/$maxJugadores",
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                                Text("${(porcentaje * 100).toInt()}%",
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: porcentaje,
                                backgroundColor: Colors.white10,
                                color: const Color(0xFF53D86A),
                                minHeight: 10,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 2.4,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: maxJugadores,
                            itemBuilder: (context, index) {
                              if (index < jugadores.length) {
                                final j = jugadores[index];
                                final esYo = j.id == partida?.jugadorLocal;
                                return _buildPlayerCard(
                                  nombre: esYo ? "Tú" : "Jugador ${index + 1}",
                                  status: "LISTO",
                                  esHost: index == 0,
                                  letra: (esYo ? "T" : "J"),
                                );
                              }
                              return _buildEmptyCard();
                            },
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(25, 8, 25, 14),
                        child: _buildBotonComenzar(
                          context,
                          partidaVm,
                          requiereSalaLlena: requiereSalaLlena,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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

  Widget _buildBotonComenzar(
    BuildContext context,
    PartidaActualViewModel vm, {
    required bool requiereSalaLlena,
  }) {
    final partida = vm.partidaActual;
    final jugadores = partida?.jugadores ?? [];
    final maxJugadores = vm.maxJugadores;

    // Host fiable: lo seteamos en el VM al crear la partida. No inferimos
    // por orden de la lista porque el backend puede devolver órdenes distintos
    // según el cliente.
    final yoSoyHost = vm.soyHost;

    final condicionInicio = requiereSalaLlena
        ? jugadores.length == maxJugadores
        : jugadores.length >= 2;

    // No-host: nunca ve el botón verde. Sólo un banner informativo.
    if (!yoSoyHost) {
      final mensaje = condicionInicio
          ? 'El anfitrión iniciará la partida'
          : 'Esperando más jugadores… (${jugadores.length}/$maxJugadores)';
      return Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF2A316B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Center(
          child: Text(
            mensaje,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    // Host: botón verde, brillante sólo si se puede iniciar.
    final canStart = condicionInicio;
    final textoBoton = canStart
        ? 'Comenzar partida'
        : requiereSalaLlena
            ? 'Esperando jugadores (${jugadores.length}/$maxJugadores)'
            : 'Esperando al menos 2 jugadores';

    return GestureDetector(
      onTap: canStart
          ? () {
              vm.iniciarPartida(vsIA: false, cantidadBots: 0);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Iniciando partida, esperando al servidor...'),
                ),
              );
            }
          : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: canStart ? 1.0 : 0.45,
        child: Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF53D86A),
            borderRadius: BorderRadius.circular(14),
            boxShadow: canStart
                ? [
                    BoxShadow(
                      color: const Color(0xFF53D86A).withOpacity(0.45),
                      blurRadius: 14,
                      spreadRadius: 3,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              textoBoton,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
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