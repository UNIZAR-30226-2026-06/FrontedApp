import 'dart:math';
import 'package:flutter/material.dart';

class TarjetaRolWidget extends StatefulWidget {
  final Map<String, dynamic>? role;
  final int usos;
  final int maxUsos;
  final bool canUseNow;
  final bool isRevealed;

  const TarjetaRolWidget({
    super.key,
    required this.role,
    this.usos = 0,
    this.maxUsos = 0,
    this.canUseNow = false,
    this.isRevealed = false,
  });

  @override
  State<TarjetaRolWidget> createState() => _TarjetaRolWidgetState();
}

class _TarjetaRolWidgetState extends State<TarjetaRolWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    // Animación de 700ms con una curva de rebote (easeOutBack) para que quede muy natural
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _flipAnimation = Tween<double>(begin: pi, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // Si entramos y ya estaba revelado (ej: reconexión), vamos al final directo
    if (widget.isRevealed) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(TarjetaRolWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambia de oculto a revelado, iniciamos el flip
    if (widget.isRevealed && !oldWidget.isRevealed) {
      _controller.forward();
    } else if (!widget.isRevealed && oldWidget.isRevealed) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.role == null && !widget.isRevealed) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final angle = _flipAnimation.value;
        // Cuando pasa de 90 grados (pi/2), cambiamos la cara que se muestra
        final isFrontVisible = angle < (pi / 2);

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Le da perspectiva 3D (para que no parezca plana)
            ..rotateY(angle),
          alignment: Alignment.center,
          child: isFrontVisible
              ? _buildCaraFrontal()
              : Transform(
            // Para que la parte trasera no se vea en modo espejo, la giramos 180 grados
            transform: Matrix4.identity()..rotateY(pi),
            alignment: Alignment.center,
            child: _buildCaraTrasera(),
          ),
        );
      },
    );
  }

  // ==========================================
  // CARA DELANTERA (La que muestra tu rol)
  // ==========================================
  Widget _buildCaraFrontal() {
    final roleName = widget.role?['name'] ?? "Rol";
    final roleDescription = widget.role?['description'] ?? "Sin descripción";
    final remainingUses = widget.maxUsos > 0 ? (widget.maxUsos - widget.usos).clamp(0, 99) : 0;

    return Container(
      width: 140,
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF161E46), Color(0xFF0A0F26)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.3), blurRadius: 15, spreadRadius: 2),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.theater_comedy, color: Color(0xFF00E5FF), size: 40),
          const SizedBox(height: 10),
          Text(
            roleName,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            roleDescription,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
          const Spacer(),
          const Divider(color: Colors.white24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Usos", style: TextStyle(color: Colors.white70, fontSize: 11)),
              Text("$remainingUses/${widget.maxUsos}", style: const TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Estado", style: TextStyle(color: Colors.white70, fontSize: 11)),
              Text(
                widget.canUseNow ? "Listo" : "Espera",
                style: TextStyle(
                  color: widget.canUseNow ? const Color(0xFF62B155) : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ==========================================
  // CARA TRASERA (El reverso de la carta)
  // ==========================================
  Widget _buildCaraTrasera() {
    return Container(
      width: 140,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1433),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.help_outline, color: Colors.white38, size: 50),
            SizedBox(height: 8),
            Text("ROL SECRETO", style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}