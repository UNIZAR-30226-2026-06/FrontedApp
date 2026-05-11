import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';
import '../providers/auth_provider.dart';

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

    // 🔥 Pedimos el número real al backend nada más entrar
    vm.cargarCantidadPausadas();

    _pageController = PageController(
      viewportFraction: 0.55,
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

  void _next() => _pageController.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
  void _prev() => _pageController.previousPage(duration: const Duration(milliseconds: 200), curve: Curves.easeOut);

  String _avatarEmoji(String? avatarId) {
    switch (avatarId) {
      case '1': return '🤖';
      case '2': return '🤠';
      case '3': return '😈';
      default: return '👤';
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF2D3473);
    const panel = Color(0xFF3A4288);
    const card = Color(0xFF2A316B);

    final usuario = context.watch<AuthProvider>().usuario;

    final modes = <Widget>[
      _ModeCardDual(
        background: card,
        title: 'Modo con roles',
        icon: Icons.theater_comedy,
        description: 'Habilidades únicas por cada rol.',
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
        description: 'Reglas modificadas por cartas.',
        leftLabel: 'Pública',
        leftColor: const Color(0xFF53D86A),
        rightLabel: 'Privada',
        rightColor: const Color(0xFF2F6BFF),
        onLeft: () => vm.onTapAction(context, 'cartas_publica'),
        onRight: () => vm.onTapAction(context, 'cartas_privada'),
      ),
      _ModeCardSingle(
        background: card,
        title: 'Personalizado',
        icon: Icons.construction,
        description: 'Juego a tu medida fusionado.',
        buttonLabel: 'Iniciar partida',
        buttonColor: const Color(0xFF2F6BFF),
        onTap: () => vm.onTapAction(context, 'personalizada_privada'),
      ),
      _ModeCardSingle(
        background: card,
        title: 'Pausadas',
        icon: Icons.save,
        description: 'Reanuda tus partidas privadas.',
        buttonLabel: 'Reanudar (${vm.cantidadPausadas})',
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
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
              child: Column(
                children: [
                  // --- TOP BAR CON DATOS REALES ---
                  Row(
                    children: [
                      _AvatarBubble(
                        emoji: _avatarEmoji(usuario?.idAvatarSeleccionado?.toString()),
                        assetPath: usuario?.avatarImage,
                      ),
                      const Spacer(),
                      _Pill(
                          background: const Color(0xFFF4C542),
                          foreground: Colors.black,
                          child: Row(children: [
                            const Icon(Icons.attach_money, size: 16),
                            const SizedBox(width: 4),
                            Text('${usuario?.monedas ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))
                          ])
                      ),
                      const SizedBox(width: 8),
                      _Pill(
                          background: const Color(0xFF7E8AA3),
                          foreground: Colors.black,
                          child: Row(children: [
                            const Icon(Icons.person, size: 16),
                            const SizedBox(width: 4),
                            Text(usuario?.nombreUsuario ?? 'Usuario', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))
                          ])
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // --- PANEL PRINCIPAL ---
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(22)),
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: Column(
                        children: [
                          const Text('¡Bienvenido!', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                          const Text('Elige un modo para empezar', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 204,
                            child: Row(
                              children: [
                                _ArrowButton(icon: Icons.chevron_left, onTap: _prev),
                                const SizedBox(width: 6),
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
                                          final scale = (1 - (t * 0.12)).clamp(0.88, 1.0);
                                          final opacity = (1 - (t * 0.4)).clamp(0.6, 1.0);
                                          return Opacity(opacity: opacity, child: Transform.scale(scale: scale, child: child));
                                        },
                                        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: modes[index]),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 6),
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

// =========================================================
// COMPONENTES DE APOYO (LOS QUE TE FALTABAN)
// =========================================================

class _AvatarBubble extends StatelessWidget {
  final String emoji;
  final String? assetPath;
  const _AvatarBubble({required this.emoji, this.assetPath});
  @override
  Widget build(BuildContext context) {
    final path = assetPath;
    Widget child = Text(emoji, style: const TextStyle(fontSize: 22));
    if (path != null && path.isNotEmpty) {
      child = path.startsWith('http')
          ? Image.network(
        path,
        width: 32,
        height: 32,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Text(emoji, style: const TextStyle(fontSize: 22)),
      )
          : Image.asset(
        path.startsWith('assets/') ? path : 'assets/images/avatares/$path',
        width: 32,
        height: 32,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Text(emoji, style: const TextStyle(fontSize: 22)),
      );
    }

    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(color: Color(0xFF263064), shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: Center(child: child),
    );
  }
}

class _Pill extends StatelessWidget {
  final Widget child;
  final Color background;
  final Color foreground;
  const _Pill({required this.child, required this.background, required this.foreground});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(14)), child: DefaultTextStyle(style: TextStyle(color: foreground), child: IconTheme(data: IconThemeData(color: foreground), child: child)));
}

class _ActionButton extends StatefulWidget {
  final String label;
  final Color background;
  final VoidCallback onTap;
  final bool isDark;
  const _ActionButton({required this.label, required this.background, required this.onTap, this.isDark = true});
  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) { setState(() => _isPressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        duration: Duration.zero,
        scale: _isPressed ? 1.08 : 1.0,
        child: AnimatedContainer(
          duration: Duration.zero,
          height: 36,
          decoration: BoxDecoration(
            color: widget.background,
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isPressed ? [BoxShadow(color: widget.background.withOpacity(0.7), blurRadius: 15, spreadRadius: 4)] : [],
          ),
          child: Center(child: Text(widget.label, style: TextStyle(color: widget.isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
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
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    const activeBlue = Color(0xFF3A6BFF);
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) { setState(() => _isPressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: Duration.zero,
        width: 36,
        height: 120,
        decoration: BoxDecoration(
          color: _isPressed ? activeBlue : const Color(0xFF2A316B),
          borderRadius: BorderRadius.circular(14),
          boxShadow: _isPressed ? [BoxShadow(color: activeBlue.withOpacity(0.7), blurRadius: 15, spreadRadius: 3)] : [],
        ),
        child: Icon(widget.icon, color: Colors.white, size: 26),
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
      padding: const EdgeInsets.all(6),
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

class _BottomItem extends StatefulWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _BottomItem({required this.selected, required this.icon, required this.label, required this.onTap});
  @override
  State<_BottomItem> createState() => _BottomItemState();
}

class _BottomItemState extends State<_BottomItem> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    const activeBlue = Color(0xFF3A6BFF);
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) { setState(() => _isPressed = false); widget.onTap(); },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          duration: Duration.zero,
          scale: _isPressed ? 1.05 : 1.0,
          child: AnimatedContainer(
            duration: Duration.zero,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: (widget.selected || _isPressed) ? activeBlue : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(widget.label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeCardDual extends StatelessWidget {
  final Color background; final String title; final String description; final IconData icon;
  final String leftLabel; final Color leftColor; final VoidCallback onLeft;
  final String rightLabel; final Color rightColor; final VoidCallback onRight;
  const _ModeCardDual({required this.background, required this.title, required this.description, required this.icon, required this.leftLabel, required this.leftColor, required this.onLeft, required this.rightLabel, required this.rightColor, required this.onRight});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 6), Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis))]), const SizedBox(height: 4), Text(description, style: const TextStyle(color: Colors.white70, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis), const Spacer(), Row(children: [Expanded(child: _ActionButton(label: leftLabel, background: leftColor, onTap: onLeft, isDark: true)), const SizedBox(width: 8), Expanded(child: _ActionButton(label: rightLabel, background: rightColor, onTap: onRight, isDark: false))])]));
}

class _ModeCardSingle extends StatelessWidget {
  final Color background; final String title; final String description; final IconData icon;
  final String buttonLabel; final Color buttonColor; final VoidCallback onTap;
  const _ModeCardSingle({required this.background, required this.title, required this.description, required this.icon, required this.buttonLabel, required this.buttonColor, required this.onTap});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 6), Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis))]), const SizedBox(height: 4), Text(description, style: const TextStyle(color: Colors.white70, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis), const Spacer(), _ActionButton(label: buttonLabel, background: buttonColor, onTap: onTap, isDark: false)]));
}