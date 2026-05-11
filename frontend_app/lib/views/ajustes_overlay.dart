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
  bool _saliendo = false;

  Future<void> _confirmarSalida() async {
    final partidaVm = context.read<PartidaActualViewModel>();

    final confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF3A4288),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '¿Seguro que deseas salirte de la partida?',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        content: const Text(
          'No se podrá deshacer esta acción. La partida se finalizará.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sí, salir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmar || !mounted) return;

    setState(() => _saliendo = true);

    await partidaVm.salirDePartidaVsIA();

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
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

                      if (context.watch<PartidaActualViewModel>().isVsIA) ...[
                        const SizedBox(height: 24),
                        const Divider(color: Colors.white10, thickness: 1.2),
                        const SizedBox(height: 16),

                        _BotonSalirPartida(
                          cargando: _saliendo,
                          onTap: _confirmarSalida,
                        ),

                        const SizedBox(height: 24),
                      ] else
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

class _BotonSalirPartida extends StatefulWidget {
  final VoidCallback onTap;
  final bool cargando;

  const _BotonSalirPartida({required this.onTap, this.cargando = false});

  @override
  State<_BotonSalirPartida> createState() => _BotonSalirPartidaState();
}

class _BotonSalirPartidaState extends State<_BotonSalirPartida> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const errorRed = Color(0xFFE53935);

    return GestureDetector(
      onTapDown: widget.cargando ? null : (_) => setState(() => _isPressed = true),
      onTapUp: widget.cargando
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onTap();
            },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 100),
        scale: _isPressed && !widget.cargando ? 1.05 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          height: 46,
          decoration: BoxDecoration(
            color: widget.cargando ? errorRed.withOpacity(0.5) : errorRed,
            borderRadius: BorderRadius.circular(14),
            boxShadow: _isPressed && !widget.cargando
                ? [BoxShadow(color: errorRed.withOpacity(0.6), blurRadius: 14, spreadRadius: 3)]
                : [const BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: Center(
            child: widget.cargando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.exit_to_app, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'SALIR DE LA PARTIDA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
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