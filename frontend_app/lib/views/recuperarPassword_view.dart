import 'package:flutter/material.dart';
import '../viewmodels/recuperarPassword_viewmodel.dart';

class RecuperarPasswordView extends StatefulWidget {
  const RecuperarPasswordView({super.key});

  @override
  State<RecuperarPasswordView> createState() => _RecuperarPasswordViewState();
}

class _RecuperarPasswordViewState extends State<RecuperarPasswordView> {
  late final RecuperarPasswordViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = RecuperarPasswordViewModel();
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3473),
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, _) {
          return Stack(
            children: [
              // BOTÓN VOLVER (Posicionado arriba a la derecha)
              Positioned(
                top: 40,
                right: 20,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                  label: const Text('Volver', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F2454),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),

              SizedBox.expand(
                child: Center( // Centramos el contenido verticalmente
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),

                        // LOGO: Corregido a la ruta de tus assets
                        Image.asset(
                          'assets/images/logo.png',
                          height: 120,
                          errorBuilder: (context, _, __) => const Icon(Icons.lock_reset, size: 100, color: Colors.orange),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'RECUPERAR CONTRASEÑA',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // INPUT DE CORREO
                        Container(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: TextField(
                            controller: vm.emailController,
                            textAlign: TextAlign.center, // Centrado como en Figma
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              hintText: 'Correo electrónico',
                              hintStyle: const TextStyle(color: Colors.grey),
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),

                        // MENSAJE DE ERROR
                        if (vm.mensajeError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Text(
                              vm.mensajeError!,
                              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                            ),
                          ),

                        const SizedBox(height: 40),

                        // BOTÓN ENVIAR (Amarillo vibrante)
                        ElevatedButton(
                          onPressed: vm.estaCargando ? null : () async {
                            bool success = await vm.enviarEmail();
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Correo de recuperación enviado con éxito'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              // Tras el éxito, volvemos al Login automáticamente
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            minimumSize: const Size(280, 60),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 10,
                          ),
                          child: vm.estaCargando
                              ? const CircularProgressIndicator(color: Color(0xFF2D3473))
                              : const Text(
                            'ENVIAR CORREO',
                            style: TextStyle(
                                color: Color(0xFF2D3473),
                                fontWeight: FontWeight.w900,
                                fontSize: 20
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}