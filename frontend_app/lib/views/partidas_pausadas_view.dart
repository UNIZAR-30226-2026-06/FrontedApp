import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/partidas_pausadas_viewmodel.dart';
import '../viewmodels/partida_actual_viewmodel.dart';
import '../repositories/partida_repository.dart';
import '../providers/auth_provider.dart';
import '../models/jugador_model.dart';

class PartidasPausadasView extends StatefulWidget {
  const PartidasPausadasView({super.key});

  @override
  State<PartidasPausadasView> createState() => _PartidasPausadasViewState();
}

class _PartidasPausadasViewState extends State<PartidasPausadasView> {
  late final PartidasPausadasViewModel _vm;

  @override
  void initState() {
    super.initState();
    final repo = context.read<PartidaRepository>();
    final usuario = context.read<AuthProvider>().usuario;
    
    // Adaptamos el usuario al modelo Jugador que espera el VM
    final miPerfil = Jugador(
      nombre: usuario?.nombreUsuario ?? 'Usuario',
      coins: usuario?.monedas ?? 0,
      avatarId: usuario?.idAvatarSeleccionado?.toString() ?? 'a1',
    );

    _vm = PartidasPausadasViewModel(repo, miPerfil);
    _vm.cargarPartidasPausadas();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF2D3473);
    const panel = Color(0xFF3A4288);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Partidas Pausadas', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: panel,
              borderRadius: BorderRadius.circular(28),
            ),
            child: ListenableBuilder(
              listenable: _vm,
              builder: (context, _) {
                if (_vm.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF53D86A)));
                }

                if (_vm.error != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text('Error: ${_vm.error}', style: const TextStyle(color: Colors.white70)),
                    ),
                  );
                }

                if (_vm.partidas.isEmpty) {
                  return const Center(
                    child: Text('No tienes partidas pausadas', 
                      style: TextStyle(color: Colors.white38, fontSize: 16, fontWeight: FontWeight.w600)),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _vm.partidas.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final partida = _vm.partidas[index];
                    return _PartidaPausadaCard(
                      partida: partida,
                      onReanudar: () => _vm.reanudarPartida(
                        context, 
                        partida.gameId, 
                        context.read<PartidaActualViewModel>()
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _PartidaPausadaCard extends StatelessWidget {
  final dynamic partida; // Usamos dynamic para evitar conflictos si PartidaModel no tiene todos los campos
  final VoidCallback onReanudar;

  const _PartidaPausadaCard({required this.partida, required this.onReanudar});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A316B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          const Icon(Icons.history, color: Colors.blueAccent, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID: ${partida.gameId}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  'Jugadores: ${partida.jugadores.length}',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onReanudar,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF53D86A),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('REANUDAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
