import 'package:flutter/material.dart';
import '../models/jugador_model.dart';
import '../models/tienda_item_model.dart';
import '../viewmodels/tienda_viewmodel.dart';
import 'package:frontend_app/views/widgets/confirmacion_dialogo.dart';

class TiendaView extends StatefulWidget {
  const TiendaView({super.key});

  @override
  State<TiendaView> createState() => _TiendaViewState();
}

class _TiendaViewState extends State<TiendaView> {
  late final TiendaViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = TiendaViewModel();
  }

  void _intentarComprar(BuildContext context, TiendaItem item) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          message: "¿Deseas comprar '${item.titulo}' por ${item.precio} monedas?",
          confirmText: "Comprar",
          onConfirm: () {
            final exito = vm.ejecutarCompra(item);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(exito
                    ? "¡Compra realizada con éxito!"
                    : "No tienes suficientes monedas para este artículo."),
                backgroundColor: exito ? Colors.green : Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF2D3473);
    const panel = Color(0xFF3A4288);
    const cardColor = Color(0xFF2A316B);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: vm,
          builder: (context, _) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Container(
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Column(
                  children: [
                    // Header
                    Row(
                      children: [
                        const Icon(Icons.store, color: Colors.white, size: 26),
                        const SizedBox(width: 10),
                        const Text(
                          'Tienda',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Spacer(),
                        _Pill(
                          background: const Color(0xFFF4C542),
                          foreground: Colors.black,
                          child: Row(
                            children: [
                              const Icon(Icons.attach_money, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                '${vm.jugador.coins} Monedas',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Botón Volver Animado
                        _HoverIconButton(
                          onTap: () => Navigator.pop(context),
                          label: 'Volver',
                          icon: Icons.arrow_back,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Filtros Animados
                    Row(
                      children: [
                        _AnimatedFilterChip(
                          label: 'Todos',
                          selected: vm.filtro == TiendaFiltro.todos,
                          onTap: () => vm.setFiltro(TiendaFiltro.todos),
                        ),
                        const SizedBox(width: 8),
                        _AnimatedFilterChip(
                          label: 'Avatares',
                          selected: vm.filtro == TiendaFiltro.avatares,
                          onTap: () => vm.setFiltro(TiendaFiltro.avatares),
                        ),
                        const SizedBox(width: 8),
                        _AnimatedFilterChip(
                          label: 'Diseño de cartas',
                          selected: vm.filtro == TiendaFiltro.disenos,
                          onTap: () => vm.setFiltro(TiendaFiltro.disenos),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 700;
                          return GridView.builder(
                            itemCount: vm.itemsFiltrados.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isWide ? 2 : 1,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: isWide ? 2.9 : 3.2,
                            ),
                            itemBuilder: (context, index) {
                              final item = vm.itemsFiltrados[index];
                              return _ShopCard(
                                background: cardColor,
                                item: item,
                                onBuy: () => _intentarComprar(context, item),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/* ================= COMPONENTES ANIMADOS ================= */

class _AnimatedBuyButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AnimatedBuyButton({required this.onTap});

  @override
  State<_AnimatedBuyButton> createState() => _AnimatedBuyButtonState();
}

class _AnimatedBuyButtonState extends State<_AnimatedBuyButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const greenBase = Color(0xFF26C84B);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: _isHovered ? 1.05 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 34,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _isHovered ? greenBase.withOpacity(0.9) : greenBase,
              borderRadius: BorderRadius.circular(12),
              boxShadow: _isHovered
                  ? [BoxShadow(color: greenBase.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 2))]
                  : [],
            ),
            child: const Center(
              child: Text(
                'Comprar',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedFilterChip extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AnimatedFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_AnimatedFilterChip> createState() => _AnimatedFilterChipState();
}

class _AnimatedFilterChipState extends State<_AnimatedFilterChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final activeBlue = const Color(0xFF3A6BFF);
    final idleBlue = const Color(0xFF263064);

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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: widget.selected ? activeBlue : (_isHovered ? activeBlue.withOpacity(0.7) : idleBlue),
              borderRadius: BorderRadius.circular(14),
              boxShadow: (_isHovered || widget.selected)
                  ? [BoxShadow(color: activeBlue.withOpacity(0.3), blurRadius: 6)]
                  : [],
            ),
            child: Text(
              widget.label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
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
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFF3A4288) : const Color(0xFF263064),
            borderRadius: BorderRadius.circular(14),
            border: _isHovered ? Border.all(color: Colors.white24) : null,
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: _isHovered ? Colors.white : Colors.white70, size: 18),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  color: _isHovered ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ================= WIDGETS DE SOPORTE ================= */

class _ShopCard extends StatelessWidget {
  final Color background;
  final TiendaItem item;
  final VoidCallback onBuy;

  const _ShopCard({required this.background, required this.item, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: const Color(0xFF1F2454), borderRadius: BorderRadius.circular(14)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: item.assetPath == null
                  ? Icon(item.tipo == TiendaItemTipo.avatar ? Icons.person : Icons.style, color: Colors.white70)
                  : Image.asset(item.assetPath!, fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(item.tipo == TiendaItemTipo.avatar ? Icons.person : Icons.style, color: Colors.white70)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.attach_money, size: 16, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(item.precio.toString(), style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800)),
                  ],
                ),
                const Spacer(),
                // BOTÓN COMPRAR REFACTORIZADO
                _AnimatedBuyButton(onTap: onBuy),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Align(
            alignment: Alignment.topRight,
            child: Text(item.tipoLabel, style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.w700, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final Widget child;
  final Color background;
  final Color foreground;
  const _Pill({required this.child, required this.background, required this.foreground});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(14)),
      child: DefaultTextStyle(
        style: TextStyle(color: foreground),
        child: IconTheme(data: IconThemeData(color: foreground), child: child),
      ),
    );
  }
}