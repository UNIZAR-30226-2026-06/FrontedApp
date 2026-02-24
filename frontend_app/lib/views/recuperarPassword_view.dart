import 'package:flutter/material.dart';
import '../viewmodels/recuperar_password_viewmodel.dart';

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
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: 800,
          height: 450,
          decoration: BoxDecoration(
            color: const Color(0xFF2D3473),
            borderRadius: BorderRadius.circular(40),
          ),
          child: ListenableBuilder(
            listenable: vm,
            builder: (context, _) {
              return Stack(
                children: [
                  Positioned(
                    top: 20,
                    right: 20,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                      label: const Text('Volver', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F2454),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),

                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // LOGO
                        Image.asset(
                          'assets/images/logo_uno.png',
                          height: 80,
                          errorBuilder: (context, _, __) => const Icon(Icons.lock_reset, size: 80, color: Colors.orange),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Recuperar contraseña',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // INPUT DE CORREO
                        SizedBox(
                          width: 400,
                          child: TextField(
                            controller: vm.emailController,
                            decoration: InputDecoration(
                              hintText: 'Correo',
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),

                        // MENSAJE DE ERROR (Si el VM detecta que no existe)
                        if (vm.mensajeError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              vm.mensajeError!,
                              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                            ),
                          ),

                        const SizedBox(height: 30),

                        ElevatedButton(
                          onPressed: vm.estaCargando ? null : () async {
                            bool success = await vm.enviarEmail();
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Correo de recuperación enviado')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700), // Amarillo exacto
                            minimumSize: const Size(220, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: vm.estaCargando
                              ? const CircularProgressIndicator(color: Color(0xFF2D3473))
                              : const Text(
                            'Enviar correo',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}