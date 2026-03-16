import 'package:flutter/material.dart';
import '../models/jugador_model.dart';
import '../viewmodels/amigos_viewmodel.dart';
import '../models/amigo_model.dart';
import 'package:frontend_app/views/widgets/confirmacion_dialogo.dart';

class AmigosView extends StatefulWidget {
  const AmigosView({super.key});

  @override
  State<AmigosView> createState() => _AmigosViewState();
}

class _AmigosViewState extends State<AmigosView> {
  late final AmigosViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = AmigosViewModel();
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  void _confirmarAccion({
    required BuildContext context,
    required String userId,
    required String mensaje,
    required VoidCallback accion,
  }) {
    final nombre = vm.getNombreUsuario(userId);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          message: mensaje.replaceAll('{nombre}', nombre),
          onConfirm: accion,
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
                    // HEADER
                    Row(
                      children: [
                        const _FriendsIcon(),
                        const SizedBox(width: 10),
                        const Text(
                          'Amigos',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                        ),
                        const Spacer(),
                        // BOTÓN VOLVER ANIMADO
                        _HoverIconButton(
                          onTap: () => Navigator.pop(context, vm.buildJugadorActualizado()),
                          label: 'Volver',
                          icon: Icons.arrow_back,
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // TABS DE NAVEGACIÓN ANIMADAS
                    Row(
                      children: [
                        Expanded(
                          child: _AnimatedTabButton(
                            label: 'Mis Amigos (${vm.friendsCount})',
                            selected: vm.tab == AmigosTab.misAmigos,
                            onTap: () => vm.setTab(AmigosTab.misAmigos),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _AnimatedTabButton(
                            label: 'Buscar',
                            selected: vm.tab == AmigosTab.buscar,
                            onTap: () => vm.setTab(AmigosTab.buscar),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _AnimatedTabButton(
                            label: 'Solicitudes (${vm.requestsCount})',
                            selected: vm.tab == AmigosTab.solicitudes,
                            onTap: () => vm.setTab(AmigosTab.solicitudes),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (vm.tab == AmigosTab.buscar) ...[
                              _SearchBox(controller: vm.searchController),
                              const SizedBox(height: 12),
                            ],

                            // LISTADO DINÁMICO
                            if (vm.tab == AmigosTab.misAmigos)
                              ...vm.misAmigos.map((u) => _UserCard(
                                user: u,
                                background: cardColor,
                                trailing: _AnimatedActionButton(
                                  label: 'Eliminar',
                                  icon: Icons.person_remove,
                                  color: const Color(0xFFE53935),
                                  onTap: () => _confirmarAccion(
                                    context: context,
                                    userId: u.id,
                                    mensaje: '¿Seguro que quieres eliminar a {nombre} de tus amigos?',
                                    accion: () => vm.eliminarAmigo(u.id),
                                  ),
                                ),
                              )),

                            if (vm.tab == AmigosTab.buscar)
                              ...vm.buscarUsuarios.map((u) => _UserCard(
                                user: u,
                                background: cardColor,
                                trailing: _AnimatedActionButton(
                                  label: 'Agregar',
                                  icon: Icons.person_add,
                                  color: const Color(0xFF2DBE4D),
                                  onTap: () => _confirmarAccion(
                                    context: context,
                                    userId: u.id,
                                    mensaje: '¿Seguro que desea agregar a {nombre} como amigo?',
                                    accion: () => vm.agregarAmigoDesdeBuscar(u.id),
                                  ),
                                ),
                              )),

                            if (vm.tab == AmigosTab.solicitudes)
                              ...vm.solicitudes.map((u) => _UserCard(
                                user: u,
                                background: cardColor,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _AnimatedActionButton(
                                      label: 'Aceptar',
                                      icon: Icons.check,
                                      color: const Color(0xFF2DBE4D),
                                      onTap: () => _confirmarAccion(
                                        context: context,
                                        userId: u.id,
                                        mensaje: '¿Quieres aceptar la solicitud de {nombre}?',
                                        accion: () => vm.aceptarSolicitud(u.id),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _AnimatedActionButton(
                                      label: 'Rechazar',
                                      icon: Icons.close,
                                      color: const Color(0xFFE53935),
                                      onTap: () => _confirmarAccion(
                                        context: context,
                                        userId: u.id,
                                        mensaje: '¿Deseas rechazar la solicitud de {nombre}?',
                                        accion: () => vm.eliminarSolicitud(u.id),
                                      ),
                                    ),
                                  ],
                                ),
                              )),

                            // MENSAJES VACÍOS
                            if (vm.tab == AmigosTab.misAmigos && vm.misAmigos.isEmpty) const _EmptyLabel(text: 'No tienes amigos todavía.'),
                            if (vm.tab == AmigosTab.buscar && vm.buscarUsuarios.isEmpty) const _EmptyLabel(text: 'No hay usuarios que coincidan.'),
                            if (vm.tab == AmigosTab.solicitudes && vm.solicitudes.isEmpty) const _EmptyLabel(text: 'No tienes solicitudes pendientes.'),
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

/* ================= COMPONENTES REFACTORIZADOS (HOVER/GLOW) ================= */

class _AnimatedActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AnimatedActionButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    bool isRed = widget.color.value == 0xFFE53935;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: _isHovered ? 1.15 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: _isHovered ? widget.color.withOpacity(0.9) : widget.color,
              borderRadius: BorderRadius.circular(10),
              boxShadow: _isHovered
                  ? [BoxShadow(color: widget.color.withOpacity(0.5), blurRadius: 15, spreadRadius: 2)]
                  : [],
            ),
            child: Row(
              children: [
                Icon(widget.icon, size: 16, color: isRed ? Colors.white : Colors.black),
                const SizedBox(width: 6),
                Text(
                  widget.label,
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: isRed ? Colors.white : Colors.black,
                      fontSize: 12
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

class _AnimatedTabButton extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AnimatedTabButton({required this.label, required this.selected, required this.onTap});

  @override
  State<_AnimatedTabButton> createState() => _AnimatedTabButtonState();
}

class _AnimatedTabButtonState extends State<_AnimatedTabButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const activeBlue = Color(0xFF2F6BFF);
    const idleBlue = Color(0xFF263064);

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
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: widget.selected ? activeBlue : (_isHovered ? activeBlue.withOpacity(0.6) : idleBlue),
              borderRadius: BorderRadius.circular(14),
              boxShadow: (widget.selected || _isHovered)
                  ? [BoxShadow(color: activeBlue.withOpacity(0.4), blurRadius: 10)]
                  : [],
            ),
            child: Center(
              child: Text(
                widget.label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
              ),
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
    const activeBlue = Color(0xFF3A6BFF);
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _isHovered ? activeBlue : const Color(0xFF263064),
              borderRadius: BorderRadius.circular(15),
              boxShadow: _isHovered ? [BoxShadow(color: activeBlue.withOpacity(0.4), blurRadius: 10)] : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(widget.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ================= WIDGETS AUXILIARES ================= */

class _FriendsIcon extends StatelessWidget {
  const _FriendsIcon();
  @override
  Widget build(BuildContext context) => Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFF263064), borderRadius: BorderRadius.circular(14)), child: const Center(child: Icon(Icons.group, color: Colors.white70)));
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBox({required this.controller});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: const Color(0xFF263064), borderRadius: BorderRadius.circular(14)), child: Row(children: [const Icon(Icons.search, color: Colors.white54), const SizedBox(width: 10), Expanded(child: TextField(controller: controller, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'Buscar usuarios...', hintStyle: TextStyle(color: Colors.white54), border: InputBorder.none)))]));
}

class _UserCard extends StatelessWidget {
  final UsuarioApp user; final Color background; final Widget trailing;
  const _UserCard({required this.user, required this.background, required this.trailing});
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(18)), child: Row(children: [_Avatar(emoji: user.avatarEmoji), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(user.nombre, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)), const SizedBox(height: 2), Text('${user.coins} monedas', style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.w700, fontSize: 11))])), trailing]));
}

class _Avatar extends StatelessWidget {
  final String emoji;
  const _Avatar({required this.emoji});
  @override
  Widget build(BuildContext context) => Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFF263064), shape: BoxShape.circle), child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))));
}

class _EmptyLabel extends StatelessWidget {
  final String text;
  const _EmptyLabel({required this.text});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(top: 18), child: Text(text, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)));
}