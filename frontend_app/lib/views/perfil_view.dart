import 'package:flutter/material.dart';
import '../models/jugador_model.dart';
import '../viewmodels/perfil_viewmodel.dart';

class PerfilScreen extends StatefulWidget {
  final Jugador jugador;

  const PerfilScreen({super.key, required this.jugador});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  late final PerfilViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = PerfilViewModel(jugadorInicial: widget.jugador);
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
          title: const Text('Cambiar nombre'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Nuevo nombre'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Guardar'),
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
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Container(
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),

                // ====================================================
                // COLUMNA PRINCIPAL
                // ====================================================
                child: Column(
                  children: [

                    // ================= HEADER FIJO =================

                    Row(
                      children: [
                        _AvatarCircle(emoji: vm.avatarSeleccionado.emoji),

                        const SizedBox(width: 12),

                        Text(
                          vm.nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(width: 8),

                        InkWell(
                          onTap: _editarNombre,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF263064),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white70,
                              size: 18,
                            ),
                          ),
                        ),

                        const Spacer(),

                        InkWell(
                          onTap: () {
                            Navigator.pop(
                              context,
                              vm.buildJugadorActualizado(),
                            );
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF263064),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.arrow_back,
                                  color: Colors.white70,
                                  size: 18,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Volver',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ================= MONEDAS FIJO =================

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4C542),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.attach_money, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '${vm.coins} Monedas',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ====================================================
                    // ZONA CON SCROLL
                    // ====================================================

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 20),

                        child: Column(
                          children: [

                            // ================= STATS =================

                            Row(
                              children: const [
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.emoji_events,
                                    value: '0',
                                    label: 'Victorias',
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.star_border,
                                    value: '0',
                                    label: 'Partidas jugadas',
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.group,
                                    value: '1',
                                    label: 'Amigos',
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // ================= AVATARES =================

                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Avatares',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            SizedBox(
                              height: 56,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: vm.avatars.length,
                                separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                                itemBuilder: (context, i) {
                                  final a = vm.avatars[i];
                                  final selected =
                                      a.id == vm.avatarSeleccionadoId;

                                  return _SelectTile(
                                    selected: selected,
                                    child: Text(
                                      a.emoji,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    onTap: () =>
                                        vm.seleccionarAvatar(a.id),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 16),

                            // ================= DISEÑO =================

                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Diseño de cartas',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            Row(
                              children: vm.skins.map((s) {
                                final selected =
                                    s.id == vm.skinSeleccionadoId;

                                return Expanded(
                                  child: Padding(
                                    padding:
                                    const EdgeInsets.only(right: 12),
                                    child: _SelectTile(
                                      selected: selected,
                                      height: 56,
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            s.emoji,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            s.nombre,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () =>
                                          vm.seleccionarSkin(s.id),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
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
}

/* ================= WIDGETS AUX ================= */

class _AvatarCircle extends StatelessWidget {
  final String emoji;

  const _AvatarCircle({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: const BoxDecoration(
        color: Color(0xFF263064),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 26),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: const Color(0xFF2A316B),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectTile extends StatelessWidget {
  final bool selected;
  final Widget child;
  final VoidCallback onTap;
  final double height;

  const _SelectTile({
    required this.selected,
    required this.child,
    required this.onTap,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final border =
    selected ? const Color(0xFFF4C542) : Colors.transparent;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 64,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF2A316B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 3),
        ),
        child: Center(child: child),
      ),
    );
  }
}