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
    const bgBlue = Color(0xFF2D3473);

    return Scaffold(
      backgroundColor: bgBlue,
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, _) {
          return Stack(
            children: [
              // BOTÓN VOLVER UNIFORMADO (Top-Right como lo tenías, pero con lógica nueva)
              Positioned(
                top: 20, // Bajamos un poco para el modo horizontal
                right: 20,
                child: _AnimatedBackPill(
                  onTap: () => Navigator.pop(context),
                ),
              ),

              SizedBox.expand(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),

                        Image.asset(
                          'assets/images/logo.png',
                          height: 100, // Un poco más pequeño para evitar overflow
                          errorBuilder: (context, _, __) => const Icon(Icons.lock_reset, size: 80, color: Colors.orange),
                        ),

                        const SizedBox(height: 15),

                        const Text(
                          'RECUPERAR CONTRASEÑA',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // INPUT DE CORREO
                        Container(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: TextField(
                            controller: vm.emailController,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              hintText: 'Correo electrónico',
                              hintStyle: const TextStyle(color: Colors.grey),
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),

                        if (vm.mensajeError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Text(
                              vm.mensajeError!,
                              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                            ),
                          ),

                        const SizedBox(height: 30),

                        // BOTÓN ENVIAR INSTANTÁNEO
                        _AnimatedActionButton(
                          label: 'ENVIAR CORREO',
                          isLoading: vm.estaCargando,
                          onTap: () async {
                            bool success = await vm.enviarEmail();
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Correo de recuperación enviado con éxito'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
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

// ---------------------------------------------------------
// COMPONENTES CON RESPUESTA 0ms Y BRILLO 0.7
// ---------------------------------------------------------

class _AnimatedActionButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  const _AnimatedActionButton({required this.label, this.onTap, required this.isLoading});

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const yellowPrimary = Color(0xFFFFD700);
    const darkBlue = Color(0xFF2D3473);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (!widget.isLoading && widget.onTap != null) widget.onTap!();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        duration: Duration.zero,
        scale: _isPressed && !widget.isLoading ? 1.08 : 1.0,
        child: AnimatedContainer(
          duration: Duration.zero,
          width: 280,
          height: 60,
          decoration: BoxDecoration(
            color: widget.isLoading ? Colors.grey : yellowPrimary,
            borderRadius: BorderRadius.circular(15),
            boxShadow: _isPressed && !widget.isLoading ? [
              BoxShadow(
                  color: yellowPrimary.withOpacity(0.7), // Brillo uniforme 0.7
                  blurRadius: 20,
                  spreadRadius: 6,
                  offset: Offset.zero
              )
            ] : [const BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: darkBlue, strokeWidth: 3))
                : Text(
              widget.label,
              style: const TextStyle(color: darkBlue, fontWeight: FontWeight.w900, fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedBackPill extends StatefulWidget {
  final VoidCallback onTap;
  const _AnimatedBackPill({required this.onTap});
  @override
  State<_AnimatedBackPill> createState() => _AnimatedBackPillState();
}

class _AnimatedBackPillState extends State<_AnimatedBackPill> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    const activeBlue = Color(0xFF3A6BFF);
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) { setState(() => _isPressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        duration: Duration.zero,
        scale: _isPressed ? 1.08 : 1.0,
        child: AnimatedContainer(
          duration: Duration.zero,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _isPressed ? activeBlue : const Color(0xFF1F2454),
            borderRadius: BorderRadius.circular(15),
            boxShadow: _isPressed ? [
              BoxShadow(
                  color: activeBlue.withOpacity(0.7),
                  blurRadius: 15,
                  spreadRadius: 4
              )
            ] : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.arrow_back, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Volver', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}