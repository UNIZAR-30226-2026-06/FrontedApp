import 'package:flutter/material.dart';
import '../models/jugador_model.dart';
import '../viewmodels/home_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  final String playerName;
  final int coins;

  const HomeScreen({
    super.key,
    required this.playerName,
    required this.coins,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = HomeViewModel(
      jugadorInicial: Jugador(nombre: widget.playerName, coins: widget.coins),
    );
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

    final size = MediaQuery.sizeOf(context);

    // Ajustes responsive (móvil vs tablet)
    final bool isSmall = size.height < 500 || size.width < 380;

    final titleSize = isSmall ? 26.0 : 30.0;
    final subtitleSize = isSmall ? 12.0 : 13.0;

    // Altura reservada para la fila de tarjetas (evita que se “aplasten”)
    final cardsHeight = isSmall ? 165.0 : 190.0;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: vm,
          builder: (context, _) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                children: [
                  // TOP BAR
                  Row(
                    children: [
                      const _Logo(),
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

                  // Panel principal con scroll por si no cabe
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
                            // Título más arriba y más pequeño
                            Text(
                              '¡Bienvenido!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: titleSize,
                                fontWeight: FontWeight.w800,
                                height: 1.05,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Elige un modo de juego para empezar',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: subtitleSize,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Zona tarjetas con altura fija para que NO se aplasten
                            SizedBox(
                              height: cardsHeight,
                              child: Row(
                                children: [
                                  _ArrowButton(
                                    icon: Icons.chevron_left,
                                    onTap: () {},
                                  ),
                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: _ModeCard(
                                            compact: true,
                                            background: card,
                                            title: 'Modo con roles',
                                            icon: Icons.theater_comedy,
                                            description:
                                            'Cada jugador recibe un rol\nespecial con habilidades únicas',
                                            onPublic: () => vm.onTapAction(context, 'roles_publica'),
                                            onPrivate: () => vm.onTapAction(context, 'roles_privada'),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _ModeCard(
                                            compact: true,
                                            background: card,
                                            title: 'Modo cartas',
                                            icon: Icons.flash_on,
                                            description:
                                            'Nuevas cartas que modifican las\nreglas del juego',
                                            onPublic: () => vm.onTapAction(context, 'cartas_publica'),
                                            onPrivate: () => vm.onTapAction(context, 'cartas_privada'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 10),
                                  _ArrowButton(
                                    icon: Icons.chevron_right,
                                    onTap: () {},
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            // ✅ Menú inferior: Tienda navega a TiendaScreen
                            _BottomMenu(
                              currentIndex: vm.bottomIndex,
                              onTap: (i) {
                                vm.selectBottomTab(i);
                                if (i == 0) vm.onTapAction(context, 'amigos');
                                if (i == 1) vm.openTienda(context); // ✅ AQUÍ
                                if (i == 2) vm.onTapAction(context, 'perfil');
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

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => Container(
            color: const Color(0xFF1F2454),
            child: const Icon(Icons.image, color: Colors.white70, size: 20),
          ),
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

class _ArrowButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;

  const _ArrowButton({required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 34,
        height: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF263064),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white70, size: 26),
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

  final bool compact;

  const _ModeCard({
    required this.background,
    required this.title,
    required this.description,
    required this.icon,
    required this.onPublic,
    required this.onPrivate,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final pad = compact ? 12.0 : 14.0;
    final titleSize = compact ? 14.0 : 16.0;
    final descSize = compact ? 11.0 : 12.5;
    final btnH = compact ? 34.0 : 40.0;

    return Container(
      padding: EdgeInsets.fromLTRB(pad, pad, pad, pad),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: compact ? 18 : 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: titleSize,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: Colors.white70,
              fontSize: descSize,
              height: 1.15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  height: btnH,
                  label: 'Partida pública',
                  background: const Color(0xFF53D86A),
                  foreground: Colors.black,
                  onTap: onPublic,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  height: btnH,
                  label: 'Partida privada',
                  background: const Color(0xFF2F6BFF),
                  foreground: Colors.white,
                  onTap: onPrivate,
                ),
              ),
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
  final Color foreground;
  final VoidCallback onTap;
  final double height;

  const _ActionButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w800,
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF2A316B),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _BottomItem(
              selected: currentIndex == 0,
              icon: Icons.group,
              label: 'Amigos',
              onTap: () => onTap(0),
            ),
          ),
          Expanded(
            child: _BottomItem(
              selected: currentIndex == 1,
              icon: Icons.store,
              label: 'Tienda',
              onTap: () => onTap(1),
            ),
          ),
          Expanded(
            child: _BottomItem(
              selected: currentIndex == 2,
              icon: Icons.person,
              label: 'Perfil',
              onTap: () => onTap(2),
            ),
          ),
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

  const _BottomItem({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFF3A6BFF) : const Color(0xFF263064);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}