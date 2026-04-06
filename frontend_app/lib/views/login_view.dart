import 'package:flutter/material.dart';
import '../viewmodels/login_viewmodel.dart';

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
    const Color bgBlue = Color(0xFF2D3473);

    return Scaffold(
      backgroundColor: bgBlue,
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, _) {
          return SizedBox.expand(
            child: Center(
              child: SingleChildScrollView(
                // BouncingScrollPhysics da ese toque "elástico" de gama alta en Android
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Image.asset(
                      'assets/images/logo.png',
                      height: 140,
                      errorBuilder: (context, _, __) =>
                      const Icon(Icons.style, size: 100, color: Colors.white24),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'INICIO DE SESIÓN',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 40),

                    _buildInput(hint: 'Email o Usuario', controller: vm.nombreController),
                    const SizedBox(height: 15),
                    _buildInput(hint: 'Contraseña', controller: vm.passwordController, isPass: true),

                    const SizedBox(height: 25),

                    // ENLACES ROJOS CON ANIMACIÓN DE PRESIÓN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _AnimatedTextLink(
                          label: 'Crear cuenta',
                          onTap: () => Navigator.pushNamed(context, '/registro'),
                        ),
                        const SizedBox(width: 25),
                        _AnimatedTextLink(
                          label: 'He olvidado mi contraseña',
                          onTap: () => Navigator.pushNamed(context, '/recuperar'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // BOTÓN INICIAR SESIÓN (CON ANIMACIÓN TÁCTIL)
                    _AnimatedLoginButton(
                      isLoading: vm.estaCargando,
                      // Llamamos directamente al método refactorizado del ViewModel
                      onTap: () => vm.ejecutarLogin(context),
                    ),
                    const SizedBox(height: 40),
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
        textAlign: TextAlign.center,
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

// ---------------------------------------------------------
// COMPONENTES ANIMADOS OPTIMIZADOS PARA MÓVIL (TAP VS HOVER)
// ---------------------------------------------------------

class _AnimatedLoginButton extends StatefulWidget {
  final VoidCallback? onTap;
  final bool isLoading;
  const _AnimatedLoginButton({this.onTap, required this.isLoading});

  @override
  State<_AnimatedLoginButton> createState() => _AnimatedLoginButtonState();
}

class _AnimatedLoginButtonState extends State<_AnimatedLoginButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const yellowPrimary = Color(0xFFFFD700);
    const darkBlue = Color(0xFF2D3473);

    return GestureDetector(
      // El evento más rápido posible en el motor de Flutter
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (widget.onTap != null) widget.onTap!();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        // Tiempo 0: Cambio de estado inmediato en el siguiente frame
        duration: Duration.zero,
        scale: _isPressed ? 1.08 : 1.0,
        child: AnimatedContainer(
          duration: Duration.zero,
          width: 320,
          height: 65,
          decoration: BoxDecoration(
            color: yellowPrimary,
            borderRadius: BorderRadius.circular(15),
            boxShadow: _isPressed
                ? [BoxShadow(
                color: yellowPrimary.withOpacity(0.7), // Tu valor exacto
                blurRadius: 25,
                spreadRadius: 6,
                offset: const Offset(0, 0)
            )]
                : [const BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(color: darkBlue, strokeWidth: 3)
            )
                : const Text(
              'INICIAR SESIÓN',
              style: TextStyle(
                  color: darkBlue,
                  fontWeight: FontWeight.w900,
                  fontSize: 22
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
        duration: const Duration(milliseconds: 100),
        scale: _isPressed ? 1.1 : 1.0,
        child: Text(
          widget.label,
          style: TextStyle(
            color: _isPressed ? Colors.redAccent : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            decoration: TextDecoration.underline,
            shadows: _isPressed ? [const Shadow(color: Colors.redAccent, blurRadius: 10)] : [],
          ),
        ),
      ),
    );
  }
}