import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/amigos_viewmodel.dart';
import 'package:frontend_app/views/widgets/confirmacion_dialogo.dart';
import '../services/api_service.dart';
import '../repositories/amigos_repository.dart';
import '../providers/auth_provider.dart';

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

    final apiService = ApiService();

    final authProvider = context.read<AuthProvider>();
    if (authProvider.usuario?.token != null) {
      apiService.setToken(authProvider.usuario!.token!);
    }

    final amigosRepo = AmigosRepository(apiService);
    vm = AmigosViewModel(repo: amigosRepo);
  }

  void _confirmarAccion({
    required BuildContext context,
    required String nombre,
    required String mensaje,
    required VoidCallback accion,
  }) {
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
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Column(
                  children: [
                    // HEADER
                    Row(
                      children: [
                        const _FriendsIcon(),
                        const SizedBox(width: 10),
                        const Text(
                          'Amigos',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                        ),
                        const Spacer(),
                        _AnimatedBackPill(
                          // Ya no pasamos el jugador actualizado, la BBDD manda
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // TABS DE NAVEGACIÓN INSTANTÁNEAS
                    Row(
                      children: [
                        Expanded(
                          child: _AnimatedTabButton(
                            label: 'Amigos (${vm.misAmigos.length})',
                            selected: vm.tab == AmigosTab.misAmigos,
                            onTap: () => vm.setTab(AmigosTab.misAmigos),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _AnimatedTabButton(
                            label: 'Buscar',
                            selected: vm.tab == AmigosTab.buscar,
                            onTap: () => vm.setTab(AmigosTab.buscar),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _AnimatedTabButton(
                            label: 'Solicitudes (${vm.solicitudes.length})',
                            selected: vm.tab == AmigosTab.solicitudes,
                            onTap: () => vm.setTab(AmigosTab.solicitudes),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Expanded(
                      child: vm.isLoading
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFF53D86A)))
                          : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            if (vm.tab == AmigosTab.buscar) ...[
                              // Añadido onSearch para disparar la petición al backend
                              _SearchBox(
                                controller: vm.searchController,
                                onSearch: () => vm.buscarUsuarios(),
                              ),
                              const SizedBox(height: 10),
                            ],

                            // LISTADO DE AMIGOS
                            if (vm.tab == AmigosTab.misAmigos)
                              ...vm.misAmigos.map((u) => _UserCard(
                                nombre: u.nombre,
                                avatarEmoji: '',
                                background: cardColor,
                                trailing: _AnimatedActionButton(
                                  label: 'Eliminar',
                                  icon: Icons.person_remove,
                                  color: const Color(0xFFE53935),
                                  onTap: () => _confirmarAccion(
                                    context: context,
                                    nombre: u.nombre,
                                    mensaje: '¿Seguro que quieres eliminar a {nombre}?',
                                    accion: () => vm.eliminarAmigo(u.nombre),
                                  ),
                                ),
                              )),

                            // BUSCAR USUARIOS
                            if (vm.tab == AmigosTab.buscar)
                              ...vm.resultadosBusqueda.map((u) => _UserCard(
                                nombre: u.nombre,
                                avatarEmoji: '🔍',
                                background: cardColor,
                                trailing: _AnimatedActionButton(
                                  label: 'Agregar',
                                  icon: Icons.person_add,
                                  color: const Color(0xFF2DBE4D),
                                  onTap: () => _confirmarAccion(
                                    context: context,
                                    nombre: u.nombre,
                                    mensaje: '¿Agregar a {nombre} como amigo?',
                                    accion: () => vm.enviarSolicitud(u.nombre),
                                  ),
                                ),
                              )),

                            // SOLICITUDES
                            if (vm.tab == AmigosTab.solicitudes)
                              ...vm.solicitudes.map((s) {
                                final nombreUser = s['nombre'] ?? 'Desconocido';
                                final idSolicitud = s['id']?.toString() ?? nombreUser;
                                return _UserCard(
                                  nombre: nombreUser,
                                  avatarEmoji: '👋',
                                  background: cardColor,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _AnimatedActionButton(
                                        label: 'Ok',
                                        icon: Icons.check,
                                        color: const Color(0xFF2DBE4D),
                                        onTap: () => _confirmarAccion(
                                          context: context,
                                          nombre: nombreUser,
                                          mensaje: '¿Aceptar a {nombre}?',
                                          accion: () => vm.responderSolicitud(idSolicitud, true),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      _AnimatedActionButton(
                                        label: 'No',
                                        icon: Icons.close,
                                        color: const Color(0xFFE53935),
                                        onTap: () => _confirmarAccion(
                                          context: context,
                                          nombre: nombreUser,
                                          mensaje: '¿Rechazar a {nombre}?',
                                          accion: () => vm.responderSolicitud(idSolicitud, false),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),

                            // LABELS DE VACÍO
                            if (vm.tab == AmigosTab.misAmigos && vm.misAmigos.isEmpty) const _EmptyLabel(text: 'No tienes amigos todavía.'),
                            if (vm.tab == AmigosTab.buscar && vm.resultadosBusqueda.isEmpty) const _EmptyLabel(text: 'No hay resultados.'),
                            if (vm.tab == AmigosTab.solicitudes && vm.solicitudes.isEmpty) const _EmptyLabel(text: 'Sin solicitudes pendientes.'),
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

/* ================= COMPONENTES UNIFORMADOS (0ms / Brillo 0.7) ================= */

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
                ? [BoxShadow(color: activeBlue.withOpacity(0.7), blurRadius: 15, spreadRadius: 4)]
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
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    bool isRed = widget.color.value == 0xFFE53935;
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) { setState(() => _isPressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        duration: Duration.zero,
        scale: _isPressed ? 1.1 : 1.0,
        child: AnimatedContainer(
          duration: Duration.zero,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: _isPressed ? [BoxShadow(color: widget.color.withOpacity(0.7), blurRadius: 12, spreadRadius: 3)] : [],
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 14, color: isRed ? Colors.white : Colors.black),
              const SizedBox(width: 4),
              Text(widget.label, style: TextStyle(fontWeight: FontWeight.w900, color: isRed ? Colors.white : Colors.black, fontSize: 11)),
            ],
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
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    const activeBlue = Color(0xFF2F6BFF);
    const idleBlue = Color(0xFF263064);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) { setState(() => _isPressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        duration: Duration.zero,
        scale: _isPressed ? 1.05 : 1.0,
        child: AnimatedContainer(
          duration: Duration.zero,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: widget.selected ? activeBlue : (_isPressed ? activeBlue.withOpacity(0.7) : idleBlue),
            borderRadius: BorderRadius.circular(14),
            boxShadow: (widget.selected || _isPressed) ? [BoxShadow(color: activeBlue.withOpacity(0.7), blurRadius: 10)] : [],
          ),
          child: Center(
            child: Text(widget.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
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
  Widget build(BuildContext context) => Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF263064), borderRadius: BorderRadius.circular(12)), child: const Center(child: Icon(Icons.group, color: Colors.white70, size: 22)));
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch; // Añadido para disparar la búsqueda
  const _SearchBox({required this.controller, required this.onSearch});

  @override
  Widget build(BuildContext context) => Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFF263064), borderRadius: BorderRadius.circular(14)),
      child: Row(
          children: [
            const Icon(Icons.search, color: Colors.white54, size: 20),
            const SizedBox(width: 10),
            Expanded(
                child: TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    onSubmitted: (_) => onSearch(), // Llama al backend al pulsar "Enter" en el teclado
                    decoration: const InputDecoration(hintText: 'Buscar usuarios...', hintStyle: TextStyle(color: Colors.white54), border: InputBorder.none)
                )
            )
          ]
      )
  );
}

class _UserCard extends StatelessWidget {
  final String nombre;
  final String avatarEmoji;
  final Color background;
  final Widget trailing;

  const _UserCard({
    required this.nombre,
    required this.avatarEmoji,
    required this.background,
    required this.trailing
  });

  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(16)),
      child: Row(
          children: [
            _Avatar(emoji: avatarEmoji),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nombre, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                    ]
                )
            ),
            trailing
          ]
      )
  );
}

class _Avatar extends StatelessWidget {
  final String emoji;
  const _Avatar({required this.emoji});
  @override
  Widget build(BuildContext context) => Container(width: 36, height: 36, decoration: const BoxDecoration(color: Color(0xFF263064), shape: BoxShape.circle), child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))));
}

class _EmptyLabel extends StatelessWidget {
  final String text;
  const _EmptyLabel({required this.text});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(top: 14), child: Text(text, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 12)));
}