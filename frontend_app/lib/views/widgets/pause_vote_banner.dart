import 'dart:async';

import 'package:flutter/material.dart';

/// Banner que se muestra cuando OTRO jugador acaba de proponer pausar la
/// partida. Tiene un timer visual de 15 s, dos botones (Sí, pausar / No)
/// y se auto-cierra si el usuario no responde.
///
/// Es presentacional: el padre maneja el VM y los callbacks.
class PauseVoteBanner extends StatefulWidget {
  final String solicitante;
  final VoidCallback onVoteYes;
  final VoidCallback onVoteNo;
  final VoidCallback onDismiss;
  final Duration autoClose;

  const PauseVoteBanner({
    super.key,
    required this.solicitante,
    required this.onVoteYes,
    required this.onVoteNo,
    required this.onDismiss,
    this.autoClose = const Duration(seconds: 15),
  });

  @override
  State<PauseVoteBanner> createState() => _PauseVoteBannerState();
}

class _PauseVoteBannerState extends State<PauseVoteBanner> {
  late int _segundosRestantes;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _segundosRestantes = widget.autoClose.inSeconds;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _segundosRestantes--);
      if (_segundosRestantes <= 0) {
        _ticker?.cancel();
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progreso = (_segundosRestantes / widget.autoClose.inSeconds)
        .clamp(0.0, 1.0);

    return Material(
      color: Colors.transparent,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutBack,
        builder: (context, v, child) => Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - v) * -30),
            child: child,
          ),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1433),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFFFD54F).withOpacity(0.55),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD54F).withOpacity(0.18),
                blurRadius: 22,
              ),
            ],
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(Icons.pause_circle_filled,
                    color: Color(0xFFFFD54F), size: 28),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          TextSpan(
                            text: widget.solicitante,
                            style: const TextStyle(
                              color: Color(0xFFFFD54F),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const TextSpan(text: ' quiere pausar la partida'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: progreso,
                        minHeight: 3,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFFFFD54F),
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Se ignora automáticamente en $_segundosRestantes s',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _miniBtn(
                    label: '✓ Pausar',
                    bg: const Color(0xFF62B155),
                    fg: Colors.white,
                    onTap: () {
                      _ticker?.cancel();
                      widget.onVoteYes();
                    },
                  ),
                  const SizedBox(height: 4),
                  _miniBtn(
                    label: '✕ Rechazar',
                    bg: Colors.white10,
                    fg: Colors.white60,
                    onTap: () {
                      _ticker?.cancel();
                      widget.onVoteNo();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniBtn({
    required String label,
    required Color bg,
    required Color fg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: bg == Colors.white10
              ? Border.all(color: Colors.white24)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
