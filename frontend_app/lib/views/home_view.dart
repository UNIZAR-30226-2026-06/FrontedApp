import 'package:flutter/material.dart';
import '../viewmodels/home_viewmodel.dart';
import 'amigos_view.dart';
import 'tienda_view.dart';
import 'perfil_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = HomeViewModel();
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  String _avatarEmoji(String avatarId) {
    switch (avatarId) {
      case 'a1': return '🤖';
      case 'a2': return '🤠';
      case 'a3': return '😈';
      default: return '👤';
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF2D3473);
    const panel = Color(0xFF3A4288);
    const card = Color(0xFF2A316B);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: vm,
          builder: (context, _) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                children: [
                  // --- TOP BAR ---
                  Row(
                    children: [
                      _AvatarBubble(emoji: _avatarEmoji(vm.jugador.avatarId)),
                      const Spacer(),
                      _Pill(
                        background: const Color(0xFFF4C542),
                        foreground: Colors.black,
                        child: Row(
                          children: [
                            const Icon(Icons.attach_money, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              vm.jugador.coins.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      _Pill(
                        background: const Color(0xFF7E8AA3),
                        foreground: Colors.black,
                        child: Row(
                          children: [
                            const Icon(Icons.person, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              vm.jugador.nombre,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // --- CUERPO PRINCIPAL ---
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: panel,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const Text(
                              '¡Bienvenido!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Elige un modo de juego para empezar',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // SECCIÓN DE MODOS (Mismo estilo de tarjetas)
                            _ModeCard(
                              background: card,
                              title: 'Modo con roles',
                              icon: Icons.theater_comedy,
                              description: 'Habilidades únicas por cada rol recibido.',
                              onPublic: () => vm.onTapAction(context, 'roles_publica'),
                              onPrivate: () => vm.onTapAction(context, 'roles_privada'),
                            ),

                            const SizedBox(height: 12),

                            _ModeCard(
                              background: card,
                              title: 'Modo cartas',
                              icon: Icons.flash_on,
                              description: 'Nuevas cartas que modifican las reglas.',
                              onPublic: () => vm.onTapAction(context, 'cartas_publica'),
                              onPrivate: () => vm.onTapAction(context, 'cartas_privada'),
                            ),

                            const SizedBox(height: 20),

                            // --- MENÚ INFERIOR ---
                            _BottomMenu(
                              currentIndex: vm.bottomIndex,
                              onTap: (index) {
                                vm.selectBottomTab(context, index);
                                // Navegación centralizada
                                
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// --- Mantenemos los Widgets Privados para no perder el estilo ---

class _AvatarBubble extends StatelessWidget {
  final String emoji;
  const _AvatarBubble({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44, height: 44,
      decoration: const BoxDecoration(color: Color(0xFF263064), shape: BoxShape.circle),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
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

class _ModeCard extends StatelessWidget {
  final Color background;
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onPublic;
  final VoidCallback onPrivate;

  const _ModeCard({
    required this.background, required this.title, required this.description,
    required this.icon, required this.onPublic, required this.onPrivate
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _ActionButton(label: 'Pública', background: const Color(0xFF53D86A), onTap: onPublic)),
              const SizedBox(width: 10),
              Expanded(child: _ActionButton(label: 'Privada', background: const Color(0xFF2F6BFF), onTap: onPrivate, isDark: false)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color background;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionButton({required this.label, required this.background, required this.onTap, this.isDark = true});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(12)),
        child: Center(child: Text(label, style: TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
      ),
    );
  }
}

class _BottomMenu extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  const _BottomMenu({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: const Color(0xFF2A316B), borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          _BottomItem(selected: currentIndex == 0, icon: Icons.group, label: 'Amigos', onTap: () => onTap(0)),
          _BottomItem(selected: currentIndex == 1, icon: Icons.store, label: 'Tienda', onTap: () => onTap(1)),
          _BottomItem(selected: currentIndex == 2, icon: Icons.person, label: 'Perfil', onTap: () => onTap(2)),
        ],
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _BottomItem({required this.selected, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF3A6BFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 5),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}