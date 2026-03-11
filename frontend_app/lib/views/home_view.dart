import 'package:flutter/material.dart';
import '../viewmodels/home_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeViewModel vm;

  // ===== Carrusel tipo ruleta =====
  late final PageController _pageController;

  static const int _kModeCount = 4; // 4 modos
  static const int _kLoopBase = 10000; // para simular infinito
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    vm = HomeViewModel();

    _pageController = PageController(
      viewportFraction: 0.53, // 2 visibles aprox
      initialPage: _kLoopBase,
    );

    _currentPage = _kLoopBase % _kModeCount;
  }

  @override
  void dispose() {
    _pageController.dispose();
    vm.dispose();
    super.dispose();
  }

  void _next() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void _prev() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  String _avatarEmoji(String avatarId) {
    switch (avatarId) {
      case 'a1':
        return '🤖';
      case 'a2':
        return '🤠';
      case 'a3':
        return '😈';
      default:
        return '👤';
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF2D3473);
    const panel = Color(0xFF3A4288);
    const card = Color(0xFF2A316B);

    // ===== Los 4 modos =====
    final modes = <Widget>[
      _ModeCardDual(
        background: card,
        title: 'Modo con roles',
        icon: Icons.theater_comedy,
        description: 'Habilidades únicas por cada rol recibido.',
        leftLabel: 'Pública',
        leftColor: const Color(0xFF53D86A),
        rightLabel: 'Privada',
        rightColor: const Color(0xFF2F6BFF),
        onLeft: () => vm.onTapAction(context, 'roles_publica'),
        onRight: () => vm.onTapAction(context, 'roles_privada'),
      ),
      _ModeCardDual(
        background: card,
        title: 'Modo cartas',
        icon: Icons.flash_on,
        description: 'Nuevas cartas que modifican las reglas.',
        leftLabel: 'Pública',
        leftColor: const Color(0xFF53D86A),
        rightLabel: 'Privada',
        rightColor: const Color(0xFF2F6BFF),
        onLeft: () => vm.onTapAction(context, 'cartas_publica'),
        onRight: () => vm.onTapAction(context, 'cartas_privada'),
      ),
      _ModeCardSingle(
        background: card,
        title: 'Modo personalizado',
        icon: Icons.construction,
        description: 'Haz el juego a tu medida, cartas y roles fusionados.',
        buttonLabel: 'Iniciar partida',
        buttonColor: const Color(0xFF2F6BFF),
        // ✅ IMPORTANTE: debe coincidir con el HomeViewModel
        onTap: () => vm.onTapAction(context, 'personalizada_privada'),
      ),
      _ModeCardSingle(
        background: card,
        title: 'Partidas pausadas',
        icon: Icons.save,
        description: 'Reanuda tus partidas privadas.',
        buttonLabel: 'Partidas pausadas (0)',
        buttonColor: const Color(0xFF2F6BFF),
        onTap: () => vm.onTapAction(context, 'pausadas_abrir'),
      ),
    ];

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

                            // ===== Carrusel (2 visibles + flechas + efecto ruleta) =====
                            SizedBox(
                              height: 170,
                              child: Row(
                                children: [
                                  _ArrowButton(
                                    icon: Icons.chevron_left,
                                    onTap: _prev,
                                  ),
                                  const SizedBox(width: 6),

                                  Expanded(
                                    child: PageView.builder(
                                      controller: _pageController,
                                      itemCount: null, // infinito
                                      onPageChanged: (i) =>
                                          setState(() => _currentPage = i % _kModeCount),
                                      itemBuilder: (context, i) {
                                        final index = i % _kModeCount;

                                        final baseChild = Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 6),
                                          child: modes[index],
                                        );

                                        // Efecto “ruleta”: scale/opacity según distancia al centro
                                        return AnimatedBuilder(
                                          animation: _pageController,
                                          builder: (context, _) {
                                            double t;
                                            if (_pageController.position.hasContentDimensions) {
                                              final page = _pageController.page ??
                                                  _pageController.initialPage.toDouble();
                                              t = (page - i).abs();
                                            } else {
                                              t = (_pageController.initialPage - i).abs().toDouble();
                                            }

                                            final scale = (1 - (t * 0.12)).clamp(0.88, 1.0);
                                            final opacity = (1 - (t * 0.35)).clamp(0.55, 1.0);

                                            return Opacity(
                                              opacity: opacity,
                                              child: Transform.scale(
                                                scale: scale,
                                                child: baseChild,
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),

                                  const SizedBox(width: 6),
                                  _ArrowButton(
                                    icon: Icons.chevron_right,
                                    onTap: _next,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // --- MENÚ INFERIOR ---
                            _BottomMenu(
                              currentIndex: vm.bottomIndex,
                              onTap: (index) {
                                vm.selectBottomTab(context, index);
                                // Tu navegación centralizada aquí
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

// -----------------------------------------
// Widgets privados (manteniendo tu estilo)
// -----------------------------------------

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 36,
        height: 130,
        decoration: BoxDecoration(
          color: const Color(0xFF2A316B),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}

class _AvatarBubble extends StatelessWidget {
  final String emoji;
  const _AvatarBubble({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: Color(0xFF263064),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 24)),
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
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(14)),
      child: DefaultTextStyle(
        style: TextStyle(color: foreground),
        child: IconTheme(data: IconThemeData(color: foreground), child: child),
      ),
    );
  }
}

class _ModeCardDual extends StatelessWidget {
  final Color background;
  final String title;
  final String description;
  final IconData icon;

  final String leftLabel;
  final Color leftColor;
  final VoidCallback onLeft;

  final String rightLabel;
  final Color rightColor;
  final VoidCallback onRight;

  const _ModeCardDual({
    required this.background,
    required this.title,
    required this.description,
    required this.icon,
    required this.leftLabel,
    required this.leftColor,
    required this.onLeft,
    required this.rightLabel,
    required this.rightColor,
    required this.onRight,
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
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: leftLabel,
                  background: leftColor,
                  onTap: onLeft,
                  isDark: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  label: rightLabel,
                  background: rightColor,
                  onTap: onRight,
                  isDark: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeCardSingle extends StatelessWidget {
  final Color background;
  final String title;
  final String description;
  final IconData icon;

  final String buttonLabel;
  final Color buttonColor;
  final VoidCallback onTap;

  const _ModeCardSingle({
    required this.background,
    required this.title,
    required this.description,
    required this.icon,
    required this.buttonLabel,
    required this.buttonColor,
    required this.onTap,
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
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const Spacer(),
          _ActionButton(
            label: buttonLabel,
            background: buttonColor,
            onTap: onTap,
            isDark: false,
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

  const _ActionButton({
    required this.label,
    required this.background,
    required this.onTap,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 36,
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
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
      decoration: BoxDecoration(
        color: const Color(0xFF2A316B),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _BottomItem(
            selected: currentIndex == 0,
            icon: Icons.group,
            label: 'Amigos',
            onTap: () => onTap(0),
          ),
          _BottomItem(
            selected: currentIndex == 1,
            icon: Icons.store,
            label: 'Tienda',
            onTap: () => onTap(1),
          ),
          _BottomItem(
            selected: currentIndex == 2,
            icon: Icons.person,
            label: 'Perfil',
            onTap: () => onTap(2),
          ),
        ],
      ),
    );
  }
}

class _BottomItem extends StatefulWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomItem({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_BottomItem> createState() => _BottomItemState();
}

class _BottomItemState extends State<_BottomItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Azul oficial de tu diseño
    const activeBlue = Color(0xFF3A6BFF);

    return Expanded(
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              // Ahora el hover también activa el color azul
              color: (widget.selected || _isHovered)
                  ? activeBlue
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              // Añadimos un pequeño brillo si es hover pero no está seleccionado
              boxShadow: (_isHovered && !widget.selected)
                  ? [BoxShadow(color: activeBlue.withOpacity(0.3), blurRadius: 8)]
                  : [],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, color: Colors.white, size: 18),
                const SizedBox(width: 5),
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
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