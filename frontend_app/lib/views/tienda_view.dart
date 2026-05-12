import 'package:flutter/material.dart';
import '../models/tienda_item_model.dart';
import '../viewmodels/tienda_viewmodel.dart';
import 'package:frontend_app/views/widgets/confirmacion_dialogo.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../repositories/tienda_repository.dart';
import '../services/api_service.dart';

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
    final apiService = ApiService();

    final auth = context.read<AuthProvider>();
    if(auth.usuario?.token != null){
      apiService.setToken(auth.usuario!.token!);
    }

    vm = TiendaViewModel(
      repo: TiendaRepository(apiService),
    );
  }

  void _intentarComprar(BuildContext context, TiendaItem item) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return ConfirmationDialog(
          message: "¿Deseas comprar '${item.titulo}' por ${item.precio} monedas?",
          confirmText: "Comprar",
          onConfirm: () async {
            final auth = context.read<AuthProvider>();

            try {
              final nuevoSaldo = await vm.ejecutarCompra(item);

              int idItem = int.parse(item.id.replaceAll(RegExp(r'[^0-9]'), '')); // Extracción del id (int)

              auth.registrarCompraExitosa(
                idItem,
                nuevoSaldo,
                esAvatar: item.tipo == TiendaItemTipo.avatar,
              );

              // Cerramos el diálogo de confirmación
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }

              // Mostramos mensaje verde de éxito
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("¡Compra realizada con éxito!"),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }

              if (context.mounted) {
                final errorMsg = e.toString().replaceAll('Exception: ', '');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMsg),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final auth = context.watch<AuthProvider>();
    final user = auth.usuario;

    if (vm.filtro == TiendaFiltro.avatares) {
      vm.actualizarInventario(user?.avataresComprados ?? []);
    }
    else if (vm.filtro == TiendaFiltro.disenos) {
      vm.actualizarInventario(user?.estilosComprados ?? []);
    }
    else {
      vm.actualizarInventario([
        ...(user?.avataresComprados ?? []),
        ...(user?.estilosComprados ?? []),
      ]);
    }

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
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Column(
                  children: [
                    // Header
                    Row(
                      children: [
                        const Icon(Icons.store, color: Colors.white, size: 24),
                        const SizedBox(width: 10),
                        const Text(
                          'Tienda',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                        ),
                        const Spacer(),
                        _Pill(
                          background: const Color(0xFFF4C542),
                          foreground: Colors.black,
                          child: Row(
                            children: [
                              const Icon(Icons.attach_money, size: 16),
                              const SizedBox(width: 4),
                              // 3. CAMBIO: Leemos las monedas reales del AuthProvider
                              Text(
                                '${context.watch<AuthProvider>().usuario?.monedas ?? 0} Monedas',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // BOTÓN VOLVER
                        _AnimatedBackPill(
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
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
                    ),

                    const SizedBox(height: 10),

                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 600;
                          return GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: vm.itemsFiltrados.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isWide ? 2 : 1,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: isWide ? 2.8 : 3.5,
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

/* ================= COMPONENTES CON RESPUESTA 0ms ================= */

class _AnimatedBackPill extends StatefulWidget {
  final VoidCallback onTap;
  const _AnimatedBackPill({required this.onTap});
  @override
  State<_AnimatedBackPill> createState() => _AnimatedBackPillState();
}

class _AnimatedBackPillState extends State<_AnimatedBackPill> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    const activeBlue = Color(0xFF3A6BFF);
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) { setState(() => _isPressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        duration: Duration.zero,
        scale: _isPressed ? 1.08 : 1.0,
        child: AnimatedContainer(
          duration: Duration.zero,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _isPressed ? activeBlue : const Color(0xFF263064),
            borderRadius: BorderRadius.circular(15),
            boxShadow: _isPressed
                ? [BoxShadow(
                color: activeBlue.withOpacity(0.7), // Brillo exacto al 0.7
                blurRadius: 15,
                spreadRadius: 4
            )]
                : [],
          ),
          child: const Row( // Corregido const Row
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text('Volver', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedBuyButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AnimatedBuyButton({required this.onTap});

  @override
  State<_AnimatedBuyButton> createState() => _AnimatedBuyButtonState();
}

class _AnimatedBuyButtonState extends State<_AnimatedBuyButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const greenBase = Color(0xFF26C84B);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) { setState(() => _isPressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        duration: Duration.zero,
        scale: _isPressed ? 1.05 : 1.0,
        child: AnimatedContainer(
          duration: Duration.zero,
          height: 32,
          width: double.infinity,
          decoration: BoxDecoration(
            color: greenBase,
            borderRadius: BorderRadius.circular(10),
            boxShadow: _isPressed
                ? [BoxShadow(color: greenBase.withOpacity(0.7), blurRadius: 12, spreadRadius: 2)]
                : [],
          ),
          child: const Center(
            child: Text('Comprar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13)),
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
  const _AnimatedFilterChip({required this.label, required this.selected, required this.onTap});

  @override
  State<_AnimatedFilterChip> createState() => _AnimatedFilterChipState();
}

class _AnimatedFilterChipState extends State<_AnimatedFilterChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const activeBlue = Color(0xFF3A6BFF);
    const idleBlue = Color(0xFF263064);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) { setState(() => _isPressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        duration: Duration.zero,
        scale: _isPressed ? 1.08 : 1.0,
        child: AnimatedContainer(
          duration: Duration.zero,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: widget.selected ? activeBlue : (_isPressed ? activeBlue.withOpacity(0.7) : idleBlue),
            borderRadius: BorderRadius.circular(14),
            boxShadow: (_isPressed || widget.selected)
                ? [BoxShadow(color: activeBlue.withOpacity(0.7), blurRadius: 10)]
                : [],
          ),
          child: Text(
            widget.label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ),
      ),
    );
  }
}


class _ShopCard extends StatelessWidget {
  final Color background;
  final TiendaItem item;
  final VoidCallback onBuy;
  const _ShopCard({required this.background, required this.item, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: const Color(0xFF1F2454), borderRadius: BorderRadius.circular(12)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Builder(
                builder: (context) {
                  final path = item.assetPath;

                  if (path == null || path.isEmpty) {
                    return Icon(item.tipo == TiendaItemTipo.avatar ? Icons.person : Icons.style, color: Colors.white70);
                  }

                  final isEmoji = !path.contains('.') && path.characters.length <= 5;

                  if (isEmoji) {
                    return Center(
                      child: Text(path, style: const TextStyle(fontSize: 28)),
                    );
                  }

                  return Image.asset(
                    path,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Center(child: Text(path, style: const TextStyle(fontSize: 28))),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.attach_money, size: 14, color: Colors.white70),
                    const SizedBox(width: 2),
                    Text(item.precio.toString(), style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800, fontSize: 12)),
                  ],
                ),
                const Spacer(),
                _AnimatedBuyButton(onTap: onBuy),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Align(
            alignment: Alignment.topRight,
            child: Text(item.tipoLabel, style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.w700, fontSize: 10)),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(14)),
      child: DefaultTextStyle(style: TextStyle(color: foreground), child: IconTheme(data: IconThemeData(color: foreground), child: child)),
    );
  }
}