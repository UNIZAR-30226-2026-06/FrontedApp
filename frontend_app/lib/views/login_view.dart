import 'package:flutter/material.dart';
import '../viewmodels/login_viewmodel.dart';
import 'home_view.dart';
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
      // Fondo azul oscuro según Figma
      backgroundColor: const Color(0xFF2D3473),
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, _) {
          return SizedBox.expand(
            child: Center( // Aseguramos que el contenido esté centrado
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // LOGO: Ajustado a la ruta real de tu carpeta assets
                    Image.asset(
                      'assets/images/logo.png',
                      height: 140,
                      errorBuilder: (context, _, __) => const Icon(Icons.style, size: 100, color: Colors.white24),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'INICIO DE SESIÓN',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 42, // Tamaño similar al de Figma
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0
                      ),
                    ),

                    const SizedBox(height: 40),

                    // INPUTS
                    _buildInput(hint: 'Usuario', controller: vm.nombreController),
                    const SizedBox(height: 15),
                    _buildInput(hint: 'Contraseña', controller: vm.passwordController, isPass: true),

                    const SizedBox(height: 25),

                    // ENLACES ROJOS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegistroView())
                          ),
                          child: const Text(
                              'Crear cuenta',
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.underline)
                          ),
                        ),
                        const SizedBox(width: 20),
                        TextButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RecuperarPasswordView())
                          ),
                          child: const Text(
                              'He olvidado mi contraseña',
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.underline)
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // BOTÓN INICIAR SESIÓN (AMARILLO FIGMA)
                    ElevatedButton(
                      onPressed: vm.estaCargando ? null : () async {
                        bool exito = await vm.intentarLogin();

                        if (exito && context.mounted) {
                          // REFACTOR: Limpiar la pila de navegación para ir al Home
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const HomeView()),
                                (Route<dynamic> route) => false, // No permite volver atrás
                          );
                        } else if (!exito && context.mounted) {
                          // Feedback visual simple si falla
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Credenciales incorrectas"))
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700), // Amarillo brillante
                        minimumSize: const Size(280, 60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 10,
                      ),
                      child: vm.estaCargando
                          ? const CircularProgressIndicator(color: Color(0xFF2D3473))
                          : const Text(
                          'INICIAR SESIÓN',
                          style: TextStyle(
                              color: Color(0xFF2D3473),
                              fontWeight: FontWeight.w900,
                              fontSize: 22
                          )
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInput({required String hint, required TextEditingController controller, bool isPass = false}) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 450),
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: TextField(
        controller: controller,
        obscureText: isPass,
        textAlign: TextAlign.center, // Centrado como en el diseño de Figma
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }
}