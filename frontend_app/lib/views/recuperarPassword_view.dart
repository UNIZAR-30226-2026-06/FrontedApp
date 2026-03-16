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
              // BOTÓN VOLVER ANIMADO (Arriba a la derecha)
              Positioned(
                top: 40,
                right: 20,
                child: _HoverIconButton(
                  onTap: () => Navigator.pop(context),
                  label: 'Volver',
                  icon: Icons.arrow_back,
                ),
              ),

              SizedBox.expand(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),

                        Image.asset(
                          'assets/images/logo.png',
                          height: 120,
                          errorBuilder: (context, _, __) => const Icon(Icons.lock_reset, size: 100, color: Colors.orange),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'RECUPERAR CONTRASEÑA',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),

                        const SizedBox(height: 40),

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
                              contentPadding: const EdgeInsets.symmetric(vertical: 20),
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

                        const SizedBox(height: 40),

                        // BOTÓN ENVIAR ANIMADO (ESTILO TIENDA/LOGIN)
                        _AnimatedActionButton(
                          label: 'ENVIAR CORREO',
                          isLoading: vm.estaCargando,
                          onTap: vm.estaCargando ? null : () async {
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
// COMPONENTES ANIMADOS ESPECÍFICOS (MANTENIENDO TU FORMATO)
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
          // ESCALA 1.15: Consistente con el Home refactorizado
          scale: _isHovered ? 1.15 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 280,
            height: 60,
            decoration: BoxDecoration(
              color: yellowPrimary,
              borderRadius: BorderRadius.circular(15),
              // RESPLANDOR NEÓN: Igual que el botón de Login
              boxShadow: _isHovered ? [
                BoxShadow(
                    color: yellowPrimary.withOpacity(0.6),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 4)
                )
              ] : [const BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
            ),
            child: Center(
              child: widget.isLoading
                  ? const CircularProgressIndicator(color: darkBlue)
                  : Text(
                widget.label,
                style: const TextStyle(color: darkBlue, fontWeight: FontWeight.w900, fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HoverIconButton extends StatefulWidget {
  final VoidCallback onTap;
  final String label;
  final IconData icon;

  const _HoverIconButton({required this.onTap, required this.label, required this.icon});

  @override
  State<_HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<_HoverIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const activeBlue = Color(0xFF3A6BFF);

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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _isHovered ? activeBlue : const Color(0xFF1F2454),
              borderRadius: BorderRadius.circular(15),
              boxShadow: _isHovered ? [BoxShadow(color: activeBlue.withOpacity(0.4), blurRadius: 10)] : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}