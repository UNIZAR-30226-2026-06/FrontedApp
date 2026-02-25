import 'package:flutter/material.dart';
import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
import 'registro_view.dart';
import 'recuperarPassword_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final LoginViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = LoginViewModel();
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
          return SizedBox.expand(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),

                  Image.asset(
                    'assets/images/logo_uno.png',
                    height: 120,
                    errorBuilder: (context, _, __) => const Icon(Icons.style, size: 100, color: Colors.red),
                  ),

                  const Text(
                    'INICIO DE SESIÓN',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5
                    ),
                  ),

                  const SizedBox(height: 40),

                  _buildInput(hint: 'Usuario', controller: vm.nombreController),
                  const SizedBox(height: 15),
                  _buildInput(hint: 'Contraseña', controller: vm.passwordController, isPass: true),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistroView())),
                        child: const Text('Crear cuenta', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                      ),
                      const SizedBox(width: 30),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RecuperarPasswordView())),
                        child: const Text('He olvidado mi contraseña', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // BOTÓN AMARILLO
                  ElevatedButton(
                    onPressed: vm.estaCargando ? null : () async {
                      bool exito = await vm.intentarLogin();
                      if (exito && context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      minimumSize: const Size(250, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 8,
                    ),
                    child: vm.estaCargando
                        ? const CircularProgressIndicator(color: Color(0xFF2D3473))
                        : const Text(
                        'INICIAR SESIÓN',
                        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)
                    ),
                  ),
                  const SizedBox(height: 40), // Espacio inferior
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInput({required String hint, required TextEditingController controller, bool isPass = false}) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400), // Mantiene los inputs elegantes
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controller,
        obscureText: isPass,
        decoration: InputDecoration(
          hintText: hint,
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}