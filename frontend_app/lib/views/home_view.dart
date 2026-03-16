import 'package:flutter/material.dart';
import '../viewmodels/home_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeViewModel vm;
  late final PageController _pageController;

  static const int _kModeCount = 4;
  static const int _kLoopBase = 10000;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    vm = HomeViewModel();
    _pageController = PageController(
      viewportFraction: 0.53,
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

  void _next() => _pageController.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
  void _prev() => _pageController.previousPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut);

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
        description: 'Juego a tu medida, cartas y roles fusionados.',
        buttonLabel: 'Iniciar partida',
        buttonColor: const Color(0xFF2F6BFF),
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
                      _Pill(background: const Color(0xFFF4C542), foreground: Colors.black, child: Row(children: [const Icon(Icons.attach_money, size: 18), const SizedBox(width: 6), Text(vm.jugador.coins.toString(), style: const TextStyle(fontWeight: FontWeight.bold))])),
                      const SizedBox(width: 10),
                      _Pill(background: const Color(0xFF7E8AA3), foreground: Colors.black, child: Row(children: [const Icon(Icons.person, size: 18), const SizedBox(width: 6), Text(vm.jugador.nombre, style: const TextStyle(fontWeight: FontWeight.bold))])),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // --- PANEL PRINCIPAL ---
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(22)),
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                      child: Column(
                        children: [
                          const Text('¡Bienvenido!', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          const Text('Elige un modo para empezar', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 20),
                          // CAROUSEL
                          SizedBox(
                            height: 180,
                            child: Row(
                              children: [
                                _ArrowButton(icon: Icons.chevron_left, onTap: _prev),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: PageView.builder(
                                    controller: _pageController,
                                    itemCount: null,
                                    onPageChanged: (i) => setState(() => _currentPage = i % _kModeCount),
                                    itemBuilder: (context, i) {
                                      final index = i % _kModeCount;
                                      return AnimatedBuilder(
                                        animation: _pageController,
                                        builder: (context, child) {
                                          double t = (_pageController.position.hasContentDimensions) ? (_pageController.page! - i).abs() : (_pageController.initialPage - i).abs().toDouble();
                                          final scale = (1 - (t * 0.15)).clamp(0.85, 1.0);
                                          final opacity = (1 - (t * 0.4)).clamp(0.5, 1.0);
                                          return Opacity(opacity: opacity, child: Transform.scale(scale: scale, child: child));
                                        },
                                        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: modes[index]),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _ArrowButton(icon: Icons.chevron_right, onTap: _next),
                              ],
                            ),
                          ),
                          const Spacer(),
                          _BottomMenu(currentIndex: vm.bottomIndex, onTap: (index) => vm.selectBottomTab(context, index)),
                        ],
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

// ---------------------------------------------------------
// COMPONENTES REFACTORIZADOS CON ESCALAS EQUILIBRADAS
// ---------------------------------------------------------

class _ActionButton extends StatefulWidget {
  final String label;
  final Color background;
  final VoidCallback onTap;
  final bool isDark;
  final double hoverScale;

  const _ActionButton({
    required this.label,
    required this.background,
    required this.onTap,
    this.isDark = true,
    required this.hoverScale,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: _isHovered ? widget.hoverScale : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 38,
            decoration: BoxDecoration(
              color: _isHovered ? widget.background.withOpacity(0.95) : widget.background,
              borderRadius: BorderRadius.circular(12),
              boxShadow: _isHovered ? [
                BoxShadow(
                    color: widget.background.withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 2)
                )
              ] : [],
            ),
            child: Center(
              child: Text(widget.label, style: TextStyle(color: widget.isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ArrowButton({required this.icon, required this.onTap});

  @override
  State<_ArrowButton> createState() => _ArrowButtonState();
}

class _ArrowButtonState extends State<_ArrowButton> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    const activeBlue = Color(0xFF3A6BFF);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 140,
          decoration: BoxDecoration(
            color: _isHovered ? activeBlue : const Color(0xFF2A316B),
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isHovered ? [BoxShadow(color: activeBlue.withOpacity(0.5), blurRadius: 20, spreadRadius: 2)] : [],
          ),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: _isHovered ? 1.12 : 1.0, // Ajustado de 1.3 a 1.12
            child: Icon(widget.icon, color: Colors.white, size: 30),
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
          _BottomItem(selected: currentIndex == 0, icon: Icons.group, label: 'Amigos', onTap: () => onTap(0)),
          _BottomItem(selected: currentIndex == 1, icon: Icons.store, label: 'Tienda', onTap: () => onTap(1)),
          _BottomItem(selected: currentIndex == 2, icon: Icons.person, label: 'Perfil', onTap: () => onTap(2)),
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
    const activeBlue = Color(0xFF3A6BFF);
    return Expanded(
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 150),
            scale: _isHovered ? 1.08 : 1.0, // Ajustado de 1.15 a 1.08
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: (widget.selected || _isHovered) ? activeBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: (_isHovered && !widget.selected) ? [BoxShadow(color: activeBlue.withOpacity(0.4), blurRadius: 15, spreadRadius: 1)] : [],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, color: Colors.white, size: 18),
                  const SizedBox(width: 5),
                  Text(widget.label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- CLASES DE SOPORTE ---
class _AvatarBubble extends StatelessWidget {
  final String emoji; const _AvatarBubble({required this.emoji});
  @override
  Widget build(BuildContext context) => Container(width: 44, height: 44, decoration: const BoxDecoration(color: Color(0xFF263064), shape: BoxShape.circle), child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))));
}

class _Pill extends StatelessWidget {
  final Widget child; final Color background; final Color foreground; const _Pill({required this.child, required this.background, required this.foreground});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(14)), child: DefaultTextStyle(style: TextStyle(color: foreground), child: IconTheme(data: IconThemeData(color: foreground), child: child)));
}

class _ModeCardDual extends StatelessWidget {
  final Color background; final String title; final String description; final IconData icon;
  final String leftLabel; final Color leftColor; final VoidCallback onLeft;
  final String rightLabel; final Color rightColor; final VoidCallback onRight;
  const _ModeCardDual({required this.background, required this.title, required this.description, required this.icon, required this.leftLabel, required this.leftColor, required this.onLeft, required this.rightLabel, required this.rightColor, required this.onRight});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, color: Colors.white, size: 22), const SizedBox(width: 8), Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis))]), const SizedBox(height: 8), Text(description, style: const TextStyle(color: Colors.white70, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis), const Spacer(), Row(children: [Expanded(child: _ActionButton(label: leftLabel, background: leftColor, onTap: onLeft, isDark: true, hoverScale: 1.10)), const SizedBox(width: 10), Expanded(child: _ActionButton(label: rightLabel, background: rightColor, onTap: onRight, isDark: false, hoverScale: 1.10))])]));
}

class _ModeCardSingle extends StatelessWidget {
  final Color background; final String title; final String description; final IconData icon;
  final String buttonLabel; final Color buttonColor; final VoidCallback onTap;
  const _ModeCardSingle({required this.background, required this.title, required this.description, required this.icon, required this.buttonLabel, required this.buttonColor, required this.onTap});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, color: Colors.white, size: 22), const SizedBox(width: 8), Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis))]), const SizedBox(height: 8), Text(description, style: const TextStyle(color: Colors.white70, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis), const Spacer(), _ActionButton(label: buttonLabel, background: buttonColor, onTap: onTap, isDark: false, hoverScale: 1.06)]));
}