import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/partida_actual_viewmodel.dart';

class AjustesOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const AjustesOverlay({
    super.key,
    required this.onClose,
  });

  @override
  State<AjustesOverlay> createState() => _AjustesOverlayState();
}

class _AjustesOverlayState extends State<AjustesOverlay> {
  bool musica = true;
  bool sonido = false;
  bool vibracion = true;

  Future<void> _confirmarYAbandonar(BuildContext context) async {
    final partidaVm = context.read<PartidaActualViewModel>();
    final confirmado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF3A4288),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '¿Abandonar partida?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Si sales ahora, la partida se borrará para todos. Esta acción no se puede deshacer.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text(
              'Sí, salir',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmado != true) return;
    if (!context.mounted) return;

    // Capturamos el navigator antes del await — el árbol puede cambiar tras
    // abandonar y dejar este context invalidado.
    final navigator = Navigator.of(context);

    await partidaVm.abandonarYBorrarPartida();

    // Cerramos el overlay (resetea _mostrandoAjustes a false en el VM).
    // Si no lo hacemos, al entrar a la próxima partida el TableroView vuelve
    // a renderizar el overlay porque ese flag persiste entre partidas.
    widget.onClose();

    navigator.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    const panelBg = Color(0xFF3A4288);
    const innerBg = Color(0xFF2A316B);
    const neonGreen = Color(0xFF53D86A);

    return Scaffold(
      backgroundColor: Colors.black87, // Un poco más oscuro para que resalte el panel
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.70,
          height: MediaQuery.of(context).size.height * 0.80,
          decoration: BoxDecoration(
            color: panelBg,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white10, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              )
            ],
          ),
          child: Column(
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 20, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'AJUSTES',
                      style: TextStyle(
                        color: neonGreen,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                    // BOTÓN CERRAR SNAPPY (Rojo)
                    _AnimatedCloseButton(onTap: widget.onClose),
                  ],
                ),
              ),

              const Divider(color: Colors.white10, thickness: 1.5, indent: 30, endIndent: 30),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'REGLAS ACTIVAS',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: innerBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: const Text(
                          "Reglas estándar de UNO activadas. El modo de juego actual incluye penalizaciones por no decir 'UNO' y robo de cartas acumulativo.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // FILAS DE AJUSTES TÁCTILES
                      _AnimatedSettingRow(
                        label: 'MÚSICA DE FONDO',
                        value: musica,
                        onChanged: (val) => setState(() => musica = val),
                      ),
                      const SizedBox(height: 10),
                      _AnimatedSettingRow(
                        label: 'EFECTOS DE SONIDO',
                        value: sonido,
                        onChanged: (val) => setState(() => sonido = val),
                      ),
                      const SizedBox(height: 10),
                      _AnimatedSettingRow(
                        label: 'VIBRACIÓN HÁPTICA',
                        value: vibracion,
                        onChanged: (val) => setState(() => vibracion = val),
                      ),

                      const SizedBox(height: 30),

                      const Divider(color: Colors.white10, thickness: 1.5),
                      const SizedBox(height: 14),
                      Center(
                        child: _AnimatedDangerButton(
                          label: 'ABANDONAR PARTIDA',
                          icon: Icons.exit_to_app,
                          onTap: () => _confirmarYAbandonar(context),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// COMPONENTES CON RESPUESTA 0ms Y BRILLO 0.7
// ---------------------------------------------------------

class _AnimatedSettingRow extends StatefulWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _AnimatedSettingRow({required this.label, required this.value, required this.onChanged});

  @override
  State<_AnimatedSettingRow> createState() => _AnimatedSettingRowState();
}

class _AnimatedSettingRowState extends State<_AnimatedSettingRow> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const neonGreen = Color(0xFF53D86A);
    const errorRed = Color(0xFFD65B5B);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: Duration.zero,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _isPressed ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: _isPressed ? Colors.white24 : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: TextStyle(
                color: _isPressed ? Colors.white : Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            Transform.scale(
              scale: 0.85,
              child: Switch(
                value: widget.value,
                onChanged: widget.onChanged,
                activeTrackColor: neonGreen,
                inactiveTrackColor: errorRed,
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedDangerButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _AnimatedDangerButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_AnimatedDangerButton> createState() => _AnimatedDangerButtonState();
}

class _AnimatedDangerButtonState extends State<_AnimatedDangerButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const errorRed = Color(0xFFE53935);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        duration: Duration.zero,
        scale: _isPressed ? 1.05 : 1.0,
        child: AnimatedContainer(
          duration: Duration.zero,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: _isPressed ? errorRed : errorRed.withOpacity(0.85),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white24, width: 1),
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: errorRed.withOpacity(0.7),
                      blurRadius: 18,
                      spreadRadius: 3,
                    ),
                  ]
                : [
                    const BoxShadow(
                      color: Colors.black45,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedCloseButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AnimatedCloseButton({required this.onTap});

  @override
  State<_AnimatedCloseButton> createState() => _AnimatedCloseButtonState();
}

class _AnimatedCloseButtonState extends State<_AnimatedCloseButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const errorRed = Color(0xFFD65B5B);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        duration: Duration.zero,
        scale: _isPressed ? 1.15 : 1.0,
        child: AnimatedContainer(
          duration: Duration.zero,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isPressed ? errorRed.withOpacity(0.2) : const Color(0xFF2A316B),
            shape: BoxShape.circle,
            boxShadow: _isPressed
                ? [BoxShadow(
                color: errorRed.withOpacity(0.7),
                blurRadius: 15,
                spreadRadius: 2
            )]
                : [],
          ),
          child: Icon(
              Icons.close,
              color: _isPressed ? errorRed : Colors.white70,
              size: 24
          ),
        ),
      ),
    );
  }
}