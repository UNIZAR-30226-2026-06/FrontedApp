import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/partida_actual_viewmodel.dart';
import '../viewmodels/tablero_viewmodel.dart';
import 'tablero_view.dart';

class SalaEsperaView extends StatelessWidget {
  final String modoJuego;

  const SalaEsperaView({super.key, required this.modoJuego});

  @override
  Widget build(BuildContext context) {
    final partidaVm = context.watch<PartidaActualViewModel>();
    final partida = partidaVm.partidaActual;
    
    // Datos de integración
    final codigo = partida?.code ?? "---";
    final jugadores = partida?.jugadores ?? [];
    final maxJugadores = 4; 
    final porcentaje = (jugadores.length / maxJugadores).clamp(0.0, 1.0);

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
                // Header: Botón Salir y Código
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBotonSalir(context, partidaVm),
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

                // Título y Modo
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

                // Barra de Progreso
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

                // Lista de Jugadores
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
                      itemCount: 4, 
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

                // Botón Comenzar
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: _buildBotonComenzar(context, partidaVm),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBotonSalir(BuildContext context, PartidaActualViewModel vm) {
    return GestureDetector(
      onTap: () {
        vm.limpiarPartida();
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E244D), 
          borderRadius: BorderRadius.circular(12)
        ),
        child: const Row(
          children: [
            Icon(Icons.keyboard_return, color: Colors.white, size: 16),
            SizedBox(width: 6),
            Text("Salir", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
          ],
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
          width: 1.5
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF3A4288), 
            child: Text(letra, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(nombre, 
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                    ),
                    if (esHost) const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.emoji_events, color: Colors.orange, size: 12)),
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
          style: TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.w600))
      ),
    );
  }

  Widget _buildBotonComenzar(BuildContext context, PartidaActualViewModel vm) {
    bool canStart = (vm.partidaActual?.jugadores.length ?? 0) >= 2;
    
    return GestureDetector(
      onTap: canStart ? () {
        // En una implementación real, aquí emitirías el evento de inicio al socket
        // y navegarías cuando el servidor responda. Por ahora simulamos:
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TableroView(miPerfil: vm.miPerfilPropio!)));
      } : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: canStart ? 1.0 : 0.5,
        child: Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF53D86A), 
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: const Color(0xFF53D86A).withOpacity(0.3), blurRadius: 10, spreadRadius: 2)
            ]
          ),
          child: const Center(
            child: Text("Comenzar partida", 
              style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w900))
          ),
        ),
      ),
    );
  }
}