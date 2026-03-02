import 'package:flutter/material.dart';
import '../viewmodels/seleccionmodo_viewmodel.dart';

class SeleccionModoView extends StatefulWidget {
  const SeleccionModoView({super.key});

  @override
  State<SeleccionModoView> createState() => _SeleccionModoViewState();
}

class _SeleccionModoViewState extends State<SeleccionModoView> {
  late final SeleccionModoViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = SeleccionModoViewModel();
  }

  @override
  Widget build(BuildContext context) {
    // Colores basados en tu Figma
    const Color azulFondo = Color(0xFF2D3473);
    const Color azulPanel = Color(0xFF3A4288);

    return Scaffold(
      backgroundColor: azulFondo,
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            decoration: BoxDecoration(
              color: azulPanel,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header con Botón Volver
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton.icon(
                    onPressed: () => vm.volver(context),
                    icon: const Icon(Icons.reply, color: Colors.white),
                    label: const Text("Volver",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ),

                const Text(
                  "UNO",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),

                const SizedBox(height: 10),

                // Icono y Títulos (Modo con roles)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.theater_comedy, color: Colors.white, size: 40),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(vm.tituloModo,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                        Text(vm.subtituloPartida,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 16)),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                const Text(
                  "Selecciona el modo de juego",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 25),

                // Botón Jugar vs IA (Rojo/Coral)
                _buildBotonModo(
                  titulo: "Jugar vs IA",
                  subtitulo: "Compite contra la IA en frenéticas partidas",
                  color: const Color(0xFFD65B5B),
                  onTap: () => vm.jugarVsIA(context),
                ),

                const SizedBox(height: 15),

                // Botón Modo Multijugador (Verde)
                _buildBotonModo(
                  titulo: "Modo Multijugador",
                  subtitulo: "Desafía a otros rivales para demostrar quién es el mejor",
                  color: const Color(0xFF53D86A),
                  onTap: () => vm.jugarVsJugador(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBotonModo({
    required String titulo,
    required String subtitulo,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Text(titulo,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitulo,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}