import 'package:flutter/material.dart';
import '../viewmodels/registro_viewmodel.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                '¡ÚNETE A LA ARENA!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 30),

              _buildInput(label: "Nombre de usuario", controller: vm.nombreController),
              _buildInput(label: "Email", controller: vm.emailController),
              _buildInput(label: "Contraseña", controller: vm.passwordController, isSecret: true),
              _buildInput(label: "Confirmar Contraseña", controller: vm.confirmarpasswordController, isSecret: true),

              const SizedBox(height: 20),

              _AnimatedRegisterButton(
                onTap: () => vm.ejecutarRegistro(context),
                isLoading: vm.cargando,
              ),

              const SizedBox(height: 20),

              _AnimatedTextLink(
                label: '¿Ya tienes cuenta? Inicia sesión',
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({required String label, required TextEditingController controller, bool isSecret = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: SizedBox(
        width: 400,
        child: TextField(
          controller: controller,
          obscureText: isSecret,
          style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: label,
            filled: true,
            fillColor: const Color(0xFFF0F0F0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// COMPONENTES ANIMADOS INSTANTÁNEOS (TAP VS HOVER)
// ---------------------------------------------------------

class _AnimatedRegisterButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isLoading;
  const _AnimatedRegisterButton({required this.onTap, this.isLoading = false});

  @override
  State<_AnimatedRegisterButton> createState() => _AnimatedRegisterButtonState();
}

class _AnimatedRegisterButtonState extends State<_AnimatedRegisterButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const orangePrimary = Colors.orange;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (!widget.isLoading) widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        duration: Duration.zero, // Respuesta instantánea
        scale: _isPressed && !widget.isLoading ? 1.08 : 1.0,
        child: AnimatedContainer(
          duration: Duration.zero, // Respuesta instantánea
          width: 280,
          height: 60,
          decoration: BoxDecoration(
            color: widget.isLoading ? Colors.grey : orangePrimary,
            borderRadius: BorderRadius.circular(15),
            boxShadow: _isPressed && !widget.isLoading ? [
              BoxShadow(
                  color: orangePrimary.withOpacity(0.7), // Opacidad al 0.7
                  blurRadius: 25,
                  spreadRadius: 6,
                  offset: Offset.zero
              )
            ] : [const BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
            )
                : const Text(
              '¡A JUGAR!',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
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
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        duration: Duration.zero,
        scale: _isPressed ? 1.1 : 1.0,
        child: Text(
          widget.label,
          style: TextStyle(
            color: _isPressed ? Colors.white : Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
            shadows: _isPressed ? [const Shadow(color: Colors.white54, blurRadius: 10)] : [],
          ),
        ),
      ),
    );
  }
}