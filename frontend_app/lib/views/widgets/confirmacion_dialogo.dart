import 'dart:ui';
import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String message;
  final VoidCallback onConfirm;
  final String confirmText;
  final String cancelText;

  const ConfirmationDialog({
    super.key,
    required this.message,
    required this.onConfirm,
    this.confirmText = "Confirmar",
    this.cancelText = "Cancelar",
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        backgroundColor: const Color(0xFF0A0E2F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Esquinas redondeadas
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          // Botón Cancelar (Rojo)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935), // Rojo Figma
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(cancelText, style: const TextStyle(color: Colors.white)),
          ),
          // Botón Confirmar (Verde)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676), // Verde Figma
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              onConfirm();
              Navigator.of(context).pop();
            },
            child: Text(confirmText, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}