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
  // Estados locales para los interruptores (Animación on/off)
  bool musica = true;
  bool sonido = false;
  bool vibracion = true;

  @override
  Widget build(BuildContext context) {
    const panelBg = Color(0xFF1E244D);
    const titleColor = Color(0xFF4CAF50);
    const sectionTitleColor = Colors.white70;

    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.65,
          height: MediaQuery.of(context).size.height * 0.70,
          decoration: BoxDecoration(
            color: panelBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white12, width: 1),
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 20)],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'AJUSTES',
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 32),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10, thickness: 1, indent: 20, endIndent: 20),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'REGLAS',
                        style: TextStyle(color: sectionTitleColor, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFF151830),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: const Center(
                          child: Text(
                            "Reglas estándar de UNO activadas.",
                            style: TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Row(
                        children: [
                          Expanded(
                              child: _buildSwitchSetting(
                                  'MÚSICA',
                                  musica,
                                      (val) => setState(() => musica = val)
                              )
                          ),
                          const SizedBox(width: 45),
                          Expanded(
                              child: _buildSwitchSetting(
                                  'VIBRACIÓN',
                                  vibracion,
                                      (val) => setState(() => vibracion = val)
                              )
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildSwitchSetting(
                          'SONIDO',
                          sonido,
                              (val) => setState(() => sonido = val)
                      ),
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

  Widget _buildSwitchSetting(String label, bool isOn, Function(bool) onChanged) {
    const activeColor = Color(0xFF4CAF50);
    const inactiveColor = Color(0xFFD65B5B);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown, // CORREGIDO: BoxFit.scaleDown en lugar de TextSelection.scale
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: isOn,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: activeColor,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: inactiveColor,
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }
} // CLASE CERRADA CORRECTAMENTE