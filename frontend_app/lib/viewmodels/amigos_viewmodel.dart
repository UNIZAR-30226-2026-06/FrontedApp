import 'package:flutter/material.dart';
import '../models/amigo_model.dart';
import '../models/jugador_model.dart';

enum AmigosTab { misAmigos, buscar, solicitudes }

class AmigosViewModel extends ChangeNotifier {
  AmigosViewModel({Jugador? jugadorInicial})
      : _jugadorBase = jugadorInicial ?? Jugador(
      nombre: "Invitado",
      coins: 0,
      avatarId: 'a0',
      skinId: 's1'
  ) {
    // Dataset “global” de usuarios
    _allUsers = const [
      UsuarioApp(id: 'j1', nombre: 'Jugador 1', avatarEmoji: '😎', coins: 300),
      UsuarioApp(id: 'j2', nombre: 'Jugador 2', avatarEmoji: '😎', coins: 300),
      UsuarioApp(id: 'j3', nombre: 'Jugador 3', avatarEmoji: '🎯', coins: 300),
      UsuarioApp(id: 'j4', nombre: 'Jugador 4', avatarEmoji: '🎯', coins: 300),
      UsuarioApp(id: 'j5', nombre: 'Jugador 5', avatarEmoji: '🧩', coins: 300),
      UsuarioApp(id: 'j6', nombre: 'Jugador 6', avatarEmoji: '🤖', coins: 300),
    ];

    // Lógica de carga de IDs (se mantiene igual)
    final hasAny = _jugadorBase.friendIds.isNotEmpty ||
        _jugadorBase.requestIds.isNotEmpty;

    _friendIds = List<String>.from(_jugadorBase.friendIds);
    _requestIds = List<String>.from(_jugadorBase.requestIds);

    if (!hasAny) {
      _friendIds = ['j1', 'j3', 'j5'];
      _requestIds = ['j2'];
    }

    searchController.addListener(() {
      _searchQuery = searchController.text;
      notifyListeners();
    });
  }

  final Jugador _jugadorBase;

  late final List<UsuarioApp> _allUsers;

  AmigosTab _tab = AmigosTab.misAmigos;
  AmigosTab get tab => _tab;

  void setTab(AmigosTab t) {
    _tab = t;
    notifyListeners();
  }

  final TextEditingController searchController = TextEditingController();
  String _searchQuery = '';

  late List<String> _friendIds;
  late List<String> _requestIds;

  int get friendsCount => _friendIds.length;
  int get requestsCount => _requestIds.length;

  List<UsuarioApp> get misAmigos =>
      _allUsers.where((u) => _friendIds.contains(u.id)).toList();

  List<UsuarioApp> get solicitudes =>
      _allUsers.where((u) => _requestIds.contains(u.id)).toList();

  List<UsuarioApp> get buscarUsuarios {
    // Buscar = todos los que NO son amigos y NO están en solicitudes
    var candidates = _allUsers.where((u) {
      final isFriend = _friendIds.contains(u.id);
      final isRequest = _requestIds.contains(u.id);
      return !isFriend && !isRequest;
    }).toList();

    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return candidates;

    return candidates.where((u) => u.nombre.toLowerCase().contains(q)).toList();
  }

  // Acciones

  void eliminarAmigo(String userId) {
    _friendIds.remove(userId);
    notifyListeners();
  }

  void agregarAmigoDesdeBuscar(String userId) {
    if (!_friendIds.contains(userId)) _friendIds.add(userId);
    notifyListeners();
  }

  // Solicitudes: aceptar = pasa a amigos
  void aceptarSolicitud(String userId) {
    _requestIds.remove(userId);
    if (!_friendIds.contains(userId)) _friendIds.add(userId);
    notifyListeners();
  }

  // Solicitudes: eliminar = se rechaza (vuelve a “buscar”, no a amigos)
  void eliminarSolicitud(String userId) {
    _requestIds.remove(userId);
    notifyListeners();
  }

  Jugador buildJugadorActualizado() {
    return _jugadorBase.copyWith(
      friendIds: List<String>.from(_friendIds),
      requestIds: List<String>.from(_requestIds),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}