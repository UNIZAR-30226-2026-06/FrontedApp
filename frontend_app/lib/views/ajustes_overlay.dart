import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    // Colores estandarizados del proyecto
    const panelBg = Color(0xFF3A4288);
    const innerBg = Color(0xFF2A316B);
    const neonGreen = Color(0xFF53D86A);

    return Scaffold(
      backgroundColor: Colors.black54, // Fondo oscurecido para el overlay
      body: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: MediaQuery.of(context).size.width * 0.65,
          height: MediaQuery.of(context).size.height * 0.75,
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
                padding: const EdgeInsets.fromLTRB(30, 24, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'AJUSTES',
                      style: TextStyle(
                        color: neonGreen,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                    // BOTÓN CERRAR ANIMADO
                    _HoverCloseButton(onTap: widget.onClose),
                  ],
                ),
              ),

              const Divider(color: Colors.white10, thickness: 1.5, indent: 30, endIndent: 30),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 25),
                      const Text(
                        'REGLAS ACTIVAS',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // CAJA DE REGLAS ESTILO "INNER"
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
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
                            fontSize: 13,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 35),

                      // FILAS DE AJUSTES ANIMADAS
                      _AnimatedSettingRow(
                        label: 'MÚSICA DE FONDO',
                        value: musica,
                        onChanged: (val) => setState(() => musica = val),
                      ),
                      const SizedBox(height: 12),
                      _AnimatedSettingRow(
                        label: 'EFECTOS DE SONIDO',
                        value: sonido,
                        onChanged: (val) => setState(() => sonido = val),
                      ),
                      const SizedBox(height: 12),
                      _AnimatedSettingRow(
                        label: 'VIBRACIÓN HÁPTICA',
                        value: vibracion,
                        onChanged: (val) => setState(() => vibracion = val),
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
// COMPONENTES ANIMADOS (GLOW & HOVER)
// ---------------------------------------------------------

class _AnimatedSettingRow extends StatefulWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AnimatedSettingRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_AnimatedSettingRow> createState() => _AnimatedSettingRowState();
}

class _AnimatedSettingRowState extends State<_AnimatedSettingRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF53D86A);
    const inactiveColor = Color(0xFFD65B5B);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: _isHovered ? Colors.white.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: _isHovered ? 1.05 : 1.0,
              child: Text(
                widget.label,
                style: TextStyle(
                  color: _isHovered ? Colors.white : Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Transform.scale(
              scale: 0.9,
              child: Switch(
                value: widget.value,
                onChanged: widget.onChanged,
                activeColor: Colors.white,
                activeTrackColor: activeColor,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: inactiveColor,
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoverCloseButton extends StatefulWidget {
  final VoidCallback onTap;
  const _HoverCloseButton({required this.onTap});

  @override
  State<_HoverCloseButton> createState() => _HoverCloseButtonState();
}

class _HoverCloseButtonState extends State<_HoverCloseButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const errorRed = Color(0xFFD65B5B);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: _isHovered ? 1.2 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isHovered ? errorRed.withOpacity(0.2) : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: _isHovered
                  ? [BoxShadow(color: errorRed.withOpacity(0.3), blurRadius: 10)]
                  : [],
            ),
            child: Icon(
                Icons.close,
                color: _isHovered ? errorRed : Colors.white70,
                size: 28
            ),
          ),
        ),
      ),
    );
  }
}