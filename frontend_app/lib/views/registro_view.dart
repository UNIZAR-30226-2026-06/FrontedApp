import 'package:flutter/material.dart';
import '../viewmodels/registro_viewmodel.dart';
import 'login_view.dart';
// IMPORTANTE: Importa aquí tu vista de inicio (Home)
// import 'home_view.dart';

class RegistroView extends StatefulWidget {
  const RegistroView({super.key});

  @override
  State<RegistroView> createState() => _RegistroViewState();
}

class _RegistroViewState extends State<RegistroView> {
  late final RegisterViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = RegisterViewModel();
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF1A1F3D),
          body: Row(
            children: [
              const Expanded(child: _SeccionLogoZorro()),
              Expanded(child: _FormularioRegistro(vm: vm)),
            ],
          ),
        );
      },
    );
  }
}

class _SeccionLogoZorro extends StatelessWidget {
  const _SeccionLogoZorro();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage('https://via.placeholder.com/500'),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _FormularioRegistro extends StatelessWidget {
  final RegisterViewModel vm;
  const _FormularioRegistro({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '¡ÚNETE A LA ARENA!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 40),

          _buildInput(label: "Nombre de usuario", controller: vm.nombreController),
          _buildInput(label: "Email", controller: vm.emailController),
          _buildInput(label: "Contraseña", controller: vm.passwordController, isSecret: true),
          _buildInput(label: "Confirmar Contraseña", controller: vm.confirmarpasswordController, isSecret: true),

          const SizedBox(height: 30),

          // BOTÓN PRINCIPAL: Registrar y entrar al juego
          ElevatedButton(
            onPressed: () async {
              bool exito = await vm.registrarUsuario();

              if (exito && context.mounted) {
                // Navegación definitiva: Limpiamos la pila y vamos al Home
                // Sustituye 'HomeView()' por el nombre exacto de tu clase de inicio
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginView()), // Cambiar por HomeView() si vas directo
                      (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              minimumSize: const Size(200, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 5,
            ),
            child: const Text(
              '¡A JUGAR!',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 20),

          // ENLACE PARA VOLVER: Registro -> Login
          TextButton(
            onPressed: () {
              // Si viniste desde el Login, pop te devuelve allí
              Navigator.pop(context);
            },
            child: const Text(
              '¿Ya tienes cuenta? Inicia sesión',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  decoration: TextDecoration.underline
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({required String label, required TextEditingController controller, bool isSecret = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: SizedBox(
        width: 400,
        child: TextField(
          controller: controller,
          obscureText: isSecret,
          style: const TextStyle(fontSize: 18, color: Colors.black),
          decoration: InputDecoration(
            hintText: label,
            filled: true,
            fillColor: const Color(0xFFF0F0F0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}