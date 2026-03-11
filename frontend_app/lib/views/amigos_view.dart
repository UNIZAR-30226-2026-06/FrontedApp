import 'package:flutter/material.dart';
import '../models/jugador_model.dart';
import '../viewmodels/amigos_viewmodel.dart';
import '../models/amigo_model.dart';
// Asegúrate de que la ruta a tu widget de confirmación sea correcta
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
    // Inicialización del ViewModel siguiendo el patrón MVVM
    vm = AmigosViewModel();
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  /* Función privada para centralizar los diálogos de confirmación
     utilizando el diseño definido en Figma.
  */
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
          // Sustituimos el comodín por el nombre real del usuario
          message: mensaje.replaceAll('{nombre}', nombre),
          onConfirm: accion,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Paleta cromática del proyecto
    const bg = Color(0xFF2D3473);
    const panel = Color(0xFF3A4288);
    const card = Color(0xFF2A316B);

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
                    // HEADER: Título y botón volver
                    Row(
                      children: [
                        const _FriendsIcon(),
                        const SizedBox(width: 10),
                        const Text(
                          'Amigos',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context, vm.buildJugadorActualizado());
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF263064),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.arrow_back, color: Colors.white70, size: 18),
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

                    const SizedBox(height: 14),

                    // TABS DE NAVEGACIÓN
                    Row(
                      children: [
                        Expanded(
                          child: _TabButton(
                            label: 'Mis Amigos (${vm.friendsCount})',
                            selected: vm.tab == AmigosTab.misAmigos,
                            onTap: () => vm.setTab(AmigosTab.misAmigos),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _TabButton(
                            label: 'Buscar Amigos',
                            selected: vm.tab == AmigosTab.buscar,
                            onTap: () => vm.setTab(AmigosTab.buscar),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _TabButton(
                            label: 'Solicitudes (${vm.requestsCount})',
                            selected: vm.tab == AmigosTab.solicitudes,
                            onTap: () => vm.setTab(AmigosTab.solicitudes),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // LISTADO DINÁMICO SEGÚN PESTAÑA SELECCIONADA
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (vm.tab == AmigosTab.buscar) ...[
                              _SearchBox(controller: vm.searchController),
                              const SizedBox(height: 12),
                            ],

                            // PESTAÑA: MIS AMIGOS
                            if (vm.tab == AmigosTab.misAmigos)
                              ...vm.misAmigos.map((u) => _UserCard(
                                user: u,
                                background: card,
                                trailing: _RedButton(
                                  label: 'Eliminar',
                                  icon: Icons.person_remove,
                                  onTap: () => _confirmarAccion(
                                    context: context,
                                    userId: u.id,
                                    mensaje: '¿Seguro que quieres eliminar a {nombre} de tus amigos?',
                                    accion: () => vm.eliminarAmigo(u.id),
                                  ),
                                ),
                              )),

                            // PESTAÑA: BUSCAR (Con diálogo de confirmación de Figma)
                            if (vm.tab == AmigosTab.buscar)
                              ...vm.buscarUsuarios.map((u) => _UserCard(
                                user: u,
                                background: card,
                                trailing: _GreenButton(
                                  label: 'Agregar',
                                  icon: Icons.person_add,
                                  onTap: () => _confirmarAccion(
                                    context: context,
                                    userId: u.id,
                                    mensaje: '¿Seguro que desea agregar a {nombre} como amigo?',
                                    accion: () => vm.agregarAmigoDesdeBuscar(u.id),
                                  ),
                                ),
                              )),

                            // PESTAÑA: SOLICITUDES
                            if (vm.tab == AmigosTab.solicitudes)
                              ...vm.solicitudes.map((u) => _UserCard(
                                user: u,
                                background: card,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _GreenButton(
                                      label: 'Aceptar',
                                      icon: Icons.check,
                                      onTap: () => _confirmarAccion(
                                        context: context,
                                        userId: u.id,
                                        mensaje: '¿Quieres aceptar la solicitud de {nombre}?',
                                        accion: () => vm.aceptarSolicitud(u.id),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    _RedButton(
                                      label: 'Rechazar',
                                      icon: Icons.close,
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

                            // MENSAJES DE LISTA VACÍA
                            if (vm.tab == AmigosTab.misAmigos && vm.misAmigos.isEmpty)
                              const _EmptyLabel(text: 'No tienes amigos todavía.'),

                            if (vm.tab == AmigosTab.buscar && vm.buscarUsuarios.isEmpty)
                              const _EmptyLabel(text: 'No hay usuarios que coincidan.'),

                            if (vm.tab == AmigosTab.solicitudes && vm.solicitudes.isEmpty)
                              const _EmptyLabel(text: 'No tienes solicitudes pendientes.'),
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

/* ================= COMPONENTES DE INTERFAZ (UI) ================= */

class _FriendsIcon extends StatelessWidget {
  const _FriendsIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF263064),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: Icon(Icons.group, color: Colors.white70),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFF2F6BFF) : const Color(0xFF263064);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBox({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF263064),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white54),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Buscar usuarios...',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UsuarioApp user;
  final Color background;
  final Widget trailing;

  const _UserCard({
    required this.user,
    required this.background,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _Avatar(emoji: user.avatarEmoji),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${user.coins} monedas',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String emoji;
  const _Avatar({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFF263064),
        shape: BoxShape.circle,
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
    );
  }
}

class _GreenButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GreenButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2DBE4D),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.black),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  fontSize: 12
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RedButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _RedButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE53935), // Color rojo Figma
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontSize: 12
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyLabel extends StatelessWidget {
  final String text;
  const _EmptyLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
      ),
    );
  }
}