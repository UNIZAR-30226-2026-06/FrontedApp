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
      backgroundColor: const Color(0xFF2D3473),
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, _) {
          return SizedBox.expand(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0
                      ),
                    ),
                    const SizedBox(height: 40),

                    _buildInput(hint: 'Usuario', controller: vm.nombreController),
                    const SizedBox(height: 15),
                    _buildInput(hint: 'Contraseña', controller: vm.passwordController, isPass: true),

                    const SizedBox(height: 25),

                    // ENLACES ROJOS ANIMADOS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _AnimatedTextLink(
                          label: 'Crear cuenta',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistroView())),
                        ),
                        const SizedBox(width: 25),
                        _AnimatedTextLink(
                          label: 'He olvidado mi contraseña',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RecuperarPasswordView())),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // BOTÓN INICIAR SESIÓN ANIMADO (AMARILLO FIGMA)
                    _AnimatedLoginButton(
                      isLoading: vm.estaCargando,
                      onTap: vm.estaCargando ? null : () async {
                        bool exito = await vm.intentarLogin();
                        if (exito && context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const HomeView()),
                                (Route<dynamic> route) => false,
                          );
                        } else if (!exito && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Credenciales incorrectas"))
                          );
                        }
                      },
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
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// COMPONENTES ANIMADOS ESPECÍFICOS DE LOGIN
// ---------------------------------------------------------

class _AnimatedLoginButton extends StatefulWidget {
  final VoidCallback? onTap;
  final bool isLoading;
  const _AnimatedLoginButton({this.onTap, required this.isLoading});

  @override
  State<_AnimatedLoginButton> createState() => _AnimatedLoginButtonState();
}

class _AnimatedLoginButtonState extends State<_AnimatedLoginButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const yellowPrimary = Color(0xFFFFD700);
    const darkBlue = Color(0xFF2D3473);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: _isHovered ? 1.1 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 320,
            height: 65,
            decoration: BoxDecoration(
              color: yellowPrimary,
              borderRadius: BorderRadius.circular(15),
              boxShadow: _isHovered ? [
                BoxShadow(
                    color: yellowPrimary.withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 4)
                )
              ] : [const BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
            ),
            child: Center(
              child: widget.isLoading
                  ? const CircularProgressIndicator(color: darkBlue)
                  : const Text(
                'INICIAR SESIÓN',
                style: TextStyle(color: darkBlue, fontWeight: FontWeight.w900, fontSize: 22),
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
              color: _isHovered ? Colors.redAccent : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              decoration: TextDecoration.underline,
              shadows: _isHovered ? [const Shadow(color: Colors.redAccent, blurRadius: 10)] : [],
            ),
          ),
        ),
      ),
    );
  }
}