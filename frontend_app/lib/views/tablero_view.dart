import 'package:flutter/material.dart';
import '../viewmodels/tablero_viewmodel.dart';
import '../models/jugador_model.dart';
import 'package:frontend_app/views/ajustes_overlay.dart';
import 'package:frontend_app/views/widgets/avatar_jugador_widget.dart';
import 'package:frontend_app/views/widgets/carta_widget.dart';
import 'package:frontend_app/views/widgets/mazo_central_widget.dart';

class TableroView extends StatefulWidget {
  final Jugador miPerfil;
  const TableroView({super.key, required this.miPerfil});

  @override
  State<TableroView> createState() => _TableroViewState();
}

class _TableroViewState extends State<TableroView> {
  late final TableroViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = TableroViewModel();
    // Preparamos la partida con el perfil recibido del Home
    vm.prepararPartida(widget.miPerfil);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, _) {
          return Stack(
            children: [
              // 1. FONDO
              _buildFondo(),

              // 2. OPONENTES
              if (vm.bots.length >= 3) ...[
                Positioned(
                  top: 150, left: 40,
                  child: AvatarJugadorWidget(participante: vm.bots[0]),
                ),
                Positioned(
                  top: 80, left: 0, right: 0,
                  child: Center(child: AvatarJugadorWidget(participante: vm.bots[1])),
                ),
                Positioned(
                  top: 150, right: 40,
                  child: AvatarJugadorWidget(participante: vm.bots[2]),
                ),
              ],

              // 3. CENTRO DE MESA
              Center(
                child: MazoCentralWidget(
                  cartaEnMesa: vm.cartaActual,
                  onRobar: () => vm.robarCarta(),
                ),
              ),

              // 4. HUD SUPERIOR (Aquí está el botón de las 3 rayas)
              _buildTopBar(),

              // 5. TU MANO
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: vm.jugadorHumano?.mano.map((carta) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: CartaWidget(
                            carta: carta,
                            onTap: () => vm.intentarTirarCarta(carta),
                          ),
                        );
                      }).toList() ?? [],
                    ),
                  ),
                ),
              ),

              if (vm.mostrandoAjustes)
                Positioned.fill(
                  child: AjustesOverlay(
                    onClose: () => vm.cerrarAjustes(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // --- ELEMENTOS DE DISEÑO ESTATICO ---
  // Estos se quedan aquí porque son específicos de esta pantalla y no se reutilizan

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

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/images/logo.png', height: 40),
            const Text(
                "0:00",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
            ),
            _botonPausa(),

            // SUSTITUIMOS EL ICON POR UN ICONBUTTON
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.cyanAccent, size: 40),
              onPressed: () {
                // Llamamos al método del ViewModel que cambia el booleano a true
                vm.abrirAjustes();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _botonPausa() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFD65B5B),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Icon(Icons.pause, color: Colors.white, size: 16),
          SizedBox(width: 4),
          Text("PAUSAR (1/4)", style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}