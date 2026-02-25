import 'package:flutter/material.dart';
import '../models/jugador_model.dart';
import '../models/tienda_item_model.dart';
import '../viewmodels/tienda_viewmodel.dart';

class TiendaScreen extends StatefulWidget {
  final Jugador jugador;

  const TiendaScreen({super.key, required this.jugador});

  @override
  State<TiendaScreen> createState() => _TiendaScreenState();
}

class _TiendaScreenState extends State<TiendaScreen> {
  late final TiendaViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = TiendaViewModel(jugador: widget.jugador);
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF2D3473);
    const panel = Color(0xFF3A4288);
    const card = Color(0xFF2A316B);

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
                    // Header: Tienda + monedas + volver
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
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF263064),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.arrow_back, color: Colors.white70, size: 18),
                                SizedBox(width: 6),
                                Text('Volver', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Filtros
                    Row(
                      children: [
                        _FilterChip(
                          label: 'Todos',
                          selected: vm.filtro == TiendaFiltro.todos,
                          onTap: () => vm.setFiltro(TiendaFiltro.todos),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Avatares',
                          selected: vm.filtro == TiendaFiltro.avatares,
                          onTap: () => vm.setFiltro(TiendaFiltro.avatares),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Diseño de cartas',
                          selected: vm.filtro == TiendaFiltro.disenos,
                          onTap: () => vm.setFiltro(TiendaFiltro.disenos),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Grid de items
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 700;
                          final crossAxisCount = isWide ? 2 : 1;

                          return GridView.builder(
                            itemCount: vm.itemsFiltrados.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: isWide ? 2.9 : 3.2,
                            ),
                            itemBuilder: (context, index) {
                              final item = vm.itemsFiltrados[index];
                              return _ShopCard(
                                background: card,
                                item: item,
                                onBuy: () => vm.comprar(context, item),
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

class _ShopCard extends StatelessWidget {
  final Color background;
  final TiendaItem item;
  final VoidCallback onBuy;

  const _ShopCard({
    required this.background,
    required this.item,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // Imagen
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF1F2454),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: item.assetPath == null
                  ? Icon(
                item.tipo == TiendaItemTipo.avatar ? Icons.person : Icons.style,
                color: Colors.white70,
              )
                  : Image.asset(
                item.assetPath!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Icon(
                  item.tipo == TiendaItemTipo.avatar ? Icons.person : Icons.style,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Texto principal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.attach_money, size: 16, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      item.precio.toString(),
                      style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  height: 34,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onBuy,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF26C84B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Comprar',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Tipo a la derecha
          Align(
            alignment: Alignment.topRight,
            child: Text(
              item.tipoLabel,
              style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFF3A6BFF) : const Color(0xFF263064);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final Widget child;
  final Color background;
  final Color foreground;

  const _Pill({
    required this.child,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DefaultTextStyle(
        style: TextStyle(color: foreground),
        child: IconTheme(
          data: IconThemeData(color: foreground),
          child: child,
        ),
      ),
    );
  }
}