import 'package:flutter/material.dart';
import '../viewmodels/registro_viewmodel.dart';

class RegistroView extends StatefulWidget {
  const RegistroView({super.key});

  @override
  State<RegistroView> createState() => _RegistroViewState();
}

class _RegistroViewState extends State<RegistroView> {
  // 1. Definimos el ViewModel. Usamos 'late' porque se inicializa en el initState.
  late final RegistroViewModel vm;

  @override
  void initState() {
    super.initState();
    // 2. Aquí nace la conexión. La vista crea su ViewModel al arrancar.
    vm = RegistroViewModel();
  }

  @override
  void dispose() {
    // 3. Importante: Limpiamos los controladores al cerrar la pantalla para no gastar memoria.
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 4. El 'ListenableBuilder' es el "Oidor". Si el VM dice notifyListeners(), esto se redibuja.
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF1A1F3D), // Tu azul oscuro
          body: Row(
            children: [
              // COLUMNA IZQUIERDA: EL ZORRO (Widget privado abajo)
              const Expanded(
                child: _SeccionLogoZorro(),
              ),

              // COLUMNA DERECHA: EL FORMULARIO (Widget privado abajo)
              Expanded(
                child: _FormularioRegistro(vm: vm),
              ),
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
          image: NetworkImage('https://via.placeholder.com/500'), // Placeholder temporal
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _FormularioRegistro extends StatelessWidget {
  final RegistroViewModel vm;
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

          _buildInput(label: "Nombre de usuario", controller: vm.usuarioController),
          _buildInput(label: "Email", controller: vm.emailController),
          _buildInput(label: "Contraseña", controller: vm.passwordController, isSecret: true),

          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: () {
              print("Intentando registrar a: ${vm.usuarioController.text}");
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