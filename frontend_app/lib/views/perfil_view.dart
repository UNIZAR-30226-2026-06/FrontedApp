import 'package:flutter/material.dart';
import '../viewmodels/perfil_viewmodel.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  late final PerfilViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = PerfilViewModel();
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  Future<void> _editarNombre() async {
    final controller = TextEditingController(text: vm.nombre);
    final nuevo = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF3A4288),
          title: const Text('Cambiar nombre', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Nuevo nombre',
              hintStyle: TextStyle(color: Colors.white38),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFF4C542))),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar', style: TextStyle(color: Colors.white70))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF4C542)),
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Guardar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
    if (nuevo != null) vm.setNombre(nuevo);
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF2D3473);
    const panel = Color(0xFF3A4288);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: vm,
          builder: (context, _) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
              child: Container(
                decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(22)),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  children: [
                    // HEADER
                    Row(
                      children: [
                        _AvatarCircle(emoji: vm.avatarSeleccionado.emoji),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  vm.nombre,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _HoverIconButton(icon: Icons.edit, onTap: _editarNombre, size: 34),
                            ],
                          ),
                        ),
                        _AnimatedBackPill(
                          onTap: () => Navigator.pop(context, vm.buildJugadorActualizado()),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: _StaticPill(
                        color: const Color(0xFFF4C542),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.attach_money, size: 16),
                            const SizedBox(width: 4),
                            Text('${vm.coins} Monedas', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            // STATS
                            Row(
                              children: [
                                Expanded(child: _AnimatedStatCard(icon: Icons.emoji_events, value: '0', label: 'Victorias', color: Colors.orange)),
                                const SizedBox(width: 8),
                                Expanded(child: _AnimatedStatCard(icon: Icons.star_border, value: '0', label: 'Partidas', color: Colors.blue)),
                                const SizedBox(width: 8),
                                Expanded(child: _AnimatedStatCard(icon: Icons.group, value: '1', label: 'Amigos', color: Colors.green)),
                              ],
                            ),

                            const SizedBox(height: 18),

                            _sectionTitle('Avatares'),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 56,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: vm.avatars.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 10),
                                itemBuilder: (context, i) {
                                  final a = vm.avatars[i];
                                  return _AnimatedSelectTile(
                                    selected: a.id == vm.avatarSeleccionadoId,
                                    onTap: () => vm.seleccionarAvatar(a.id),
                                    child: Text(a.emoji, style: const TextStyle(fontSize: 24)),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 18),

                            _sectionTitle('Diseño de cartas'),
                            const SizedBox(height: 10),
                            // REDUCCIÓN DE TAMAÑO: Padding lateral para que los botones no se estiren tanto
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 60),
                              child: Row(
                                children: vm.skins.map((s) {
                                  return Expanded(
                                    child: Padding(
                                      // Aumento de margen entre botones para evitar solapamiento de glow
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: _AnimatedSelectTile(
                                        selected: s.id == vm.skinSeleccionadoId,
                                        onTap: () => vm.seleccionarSkin(s.id),
                                        height: 42, // Ligeramente más bajos
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(s.emoji, style: const TextStyle(fontSize: 16)),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                  s.nombre,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
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

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
    );
  }
}

// ---------------------------------------------------------
// COMPONENTES CON RESPUESTA 0ms Y BRILLO 0.7
// ---------------------------------------------------------

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
                color: activeBlue.withOpacity(0.7),
                blurRadius: 15,
                spreadRadius: 4
            )]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
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

class _AnimatedSelectTile extends StatefulWidget {
  final bool selected;
  final Widget child;
  final VoidCallback onTap;
  final double height;
  const _AnimatedSelectTile({required this.selected, required this.child, required this.onTap, this.height = 56});

  @override
  State<_AnimatedSelectTile> createState() => _AnimatedSelectTileState();
}

class _AnimatedSelectTileState extends State<_AnimatedSelectTile> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFF4C542);
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) { setState(() => _isPressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        duration: Duration.zero,
        scale: (widget.selected || _isPressed) ? 1.08 : 1.0,
        child: AnimatedContainer(
          duration: Duration.zero,
          height: widget.height,
          constraints: const BoxConstraints(minWidth: 56),
          decoration: BoxDecoration(
            color: const Color(0xFF2A316B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.selected ? gold : Colors.transparent, width: 2.5),
            boxShadow: (widget.selected || _isPressed)
                ? [BoxShadow(color: gold.withOpacity(0.7), blurRadius: 12, spreadRadius: 2)]
                : [],
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}

class _AnimatedStatCard extends StatefulWidget {
  final IconData icon; final String value; final String label; final Color color;
  const _AnimatedStatCard({required this.icon, required this.value, required this.label, required this.color});
  @override
  State<_AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<_AnimatedStatCard> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        duration: Duration.zero,
        scale: _isPressed ? 1.05 : 1.0,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF2A316B),
            borderRadius: BorderRadius.circular(18),
            boxShadow: _isPressed ? [BoxShadow(color: widget.color.withOpacity(0.7), blurRadius: 12, spreadRadius: 2)] : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: _isPressed ? widget.color : Colors.white70, size: 20),
              const SizedBox(height: 4),
              Text(widget.value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
              Text(widget.label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HoverIconButton extends StatefulWidget {
  final IconData icon; final VoidCallback onTap; final double size;
  const _HoverIconButton({required this.icon, required this.onTap, this.size = 34});
  @override
  State<_HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<_HoverIconButton> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) { setState(() => _isPressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        duration: Duration.zero,
        scale: _isPressed ? 1.1 : 1.0,
        child: AnimatedContainer(
          duration: Duration.zero,
          width: widget.size, height: widget.size,
          decoration: BoxDecoration(
            color: _isPressed ? const Color(0xFF3A4288) : const Color(0xFF263064),
            borderRadius: BorderRadius.circular(10),
            boxShadow: _isPressed ? [BoxShadow(color: Colors.white10, blurRadius: 10)] : [],
          ),
          child: Icon(widget.icon, color: _isPressed ? Colors.white : Colors.white70, size: 16),
        ),
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  final String emoji; const _AvatarCircle({required this.emoji});
  @override
  Widget build(BuildContext context) => Container(width: 42, height: 42, decoration: const BoxDecoration(color: Color(0xFF263064), shape: BoxShape.circle), child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))));
}

class _StaticPill extends StatelessWidget {
  final Widget child; final Color color; const _StaticPill({required this.child, required this.color});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)), child: child);
}