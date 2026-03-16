import 'package:flutter/material.dart';
import '../viewmodels/registro_viewmodel.dart';
import 'login_view.dart';

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
    // Azul oficial del diseño de vuestro proyecto
    const Color bgBlue = Color(0xFF2D3473);

    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: bgBlue,
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
          // Recomendación: Usar vuestro logo.png para mantener uniformidad
          image: AssetImage('assets/images/logo.png'),
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

          // BOTÓN PRINCIPAL ANIMADO: ¡A JUGAR!
          _AnimatedRegisterButton(
            onTap: () async {
              bool exito = await vm.registrarUsuario();
              if (exito && context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginView()),
                      (route) => false,
                );
              }
            },
          ),

          const SizedBox(height: 25),

          // ENLACE ANIMADO PARA VOLVER
          _AnimatedTextLink(
            label: '¿Ya tienes cuenta? Inicia sesión',
            onTap: () => Navigator.pop(context),
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
          style: const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: label,
            filled: true,
            fillColor: const Color(0xFFF0F0F0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// COMPONENTES ANIMADOS ESPECÍFICOS DE REGISTRO
// ---------------------------------------------------------

class _AnimatedRegisterButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AnimatedRegisterButton({required this.onTap});

  @override
  State<_AnimatedRegisterButton> createState() => _AnimatedRegisterButtonState();
}

class _AnimatedRegisterButtonState extends State<_AnimatedRegisterButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const orangePrimary = Colors.orange;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          // IGUALADO A LA TIENDA: Escala 1.1 para impacto visual
          scale: _isHovered ? 1.1 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 280,
            height: 60,
            decoration: BoxDecoration(
              color: orangePrimary,
              borderRadius: BorderRadius.circular(15),
              // IGUALADO A LA TIENDA: Resplandor con blur 15 y spread 2
              boxShadow: _isHovered ? [
                BoxShadow(
                    color: orangePrimary.withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 4)
                )
              ] : [const BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
            ),
            child: const Center(
              child: Text(
                '¡A JUGAR!',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedTextLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _AnimatedTextLink({required this.label, required this.onTap});

  @override
  State<_AnimatedTextLink> createState() => _AnimatedTextLinkState();
}

class _AnimatedTextLinkState extends State<_AnimatedTextLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: _isHovered ? 1.1 : 1.0,
          child: Text(
            widget.label,
            style: TextStyle(
              color: _isHovered ? Colors.white : Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              // Sombra blanca sutil en hover para el efecto de brillo
              shadows: _isHovered ? [const Shadow(color: Colors.white54, blurRadius: 10)] : [],
            ),
          ),
        ),
      ),
    );
  }
}