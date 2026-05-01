import 'package:flutter/material.dart';
import '../models/jugador_model.dart';
import '../models/perfil_models.dart';
import '../models/tienda_item_model.dart';
import '../repositories/user_repository.dart';

class PerfilViewModel extends ChangeNotifier {
  PerfilViewModel({Jugador? jugadorInicial, UserRepository? repo})
      : _nombre = jugadorInicial?.nombre ?? "Jugador",
        _correo = jugadorInicial?.correo ?? '',
        _coins = jugadorInicial?.coins ?? 0,
        _avatarSeleccionadoId = jugadorInicial?.avatarId ?? '0',
        _skinSeleccionadoId = jugadorInicial?.skinId ?? '1',
        _repo = repo {

    cargarPersonalizacion();
  }

  final UserRepository? _repo;

  String _nombre;
  String _correo;
  int _coins;

  String get nombre => _nombre;
  int get coins => _coins;

  List<AvatarItem> _avatars = [];
  List<CardSkinItem> _skins = [];

  List<AvatarItem> get avatars => _avatars;
  List<CardSkinItem> get skins => _skins;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  String _avatarSeleccionadoId;
  String _skinSeleccionadoId;

  String get avatarSeleccionadoId => _avatarSeleccionadoId;
  String get skinSeleccionadoId => _skinSeleccionadoId;

  // Protegemos el getter para que no crashee si la lista está vacía mientras carga
  AvatarItem get avatarSeleccionado {
    if (_avatars.isEmpty) return const AvatarItem(id: '0', emoji: '👤', nombre: 'Cargando...');
    return _avatars.firstWhere((a) => a.id == _avatarSeleccionadoId, orElse: () => _avatars.first);
  }

  CardSkinItem get skinSeleccionado {
    if (_skins.isEmpty) return const CardSkinItem(id: '1', nombre: 'Cargando...', emoji: '🃏');
    return _skins.firstWhere((s) => s.id == _skinSeleccionadoId, orElse: () => _skins.first);
  }

  Future<void> cargarPersonalizacion() async {
    if (_repo == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repo!.getProfile(),
        _repo!.getPurchasedAvatars(),
        _repo!.getPurchasedStyles(),
      ]);

      final perfil = results[0] as Jugador;
      final avatares = results[1] as List<TiendaItem>;
      final estilos = results[2] as List<TiendaItem>;

      _nombre = perfil.nombre.isNotEmpty ? perfil.nombre : _nombre;
      _correo = perfil.correo;
      _coins = perfil.coins;
      _avatarSeleccionadoId = perfil.avatarId;
      _skinSeleccionadoId = perfil.skinId;

      _avatars = avatares.isNotEmpty
          ? avatares.map((item) => AvatarItem(id: item.id, emoji: '👤', nombre: item.titulo, assetPath: item.assetPath)).toList()
          : [const AvatarItem(id: '0', emoji: '👤', nombre: 'Default')];

      _skins = estilos.isNotEmpty
          ? estilos.map((item) => CardSkinItem(id: item.id, nombre: item.titulo, emoji: '🃏', assetPath: item.assetPath)).toList()
          : [const CardSkinItem(id: '1', nombre: 'Classic', emoji: '🃏')];

    } catch (e) {
      _error = 'No se pudo cargar la personalización';
      debugPrint('Error cargando personalización: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> seleccionarAvatar(String id) async {
    final previous = _avatarSeleccionadoId;
    _avatarSeleccionadoId = id;
    notifyListeners();

    try {
      await _repo?.updateAvatar(id);
    } catch (e) {
      _avatarSeleccionadoId = previous;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> seleccionarSkin(String id) async {
    final previous = _skinSeleccionadoId;
    _skinSeleccionadoId = id;
    notifyListeners();

    try {
      await _repo?.updateStyle(id);
    } catch (e) {
      _skinSeleccionadoId = previous;
      notifyListeners();
      rethrow;
    }
  }

  void setNombre(String nuevoNombre) {
    final n = nuevoNombre.trim();
    if (n.isEmpty) return;
    _nombre = n;
    notifyListeners();
  }

  Jugador buildJugadorActualizado() {
    return Jugador(
      nombre: _nombre,
      correo: _correo,
      coins: _coins,
      avatarId: _avatarSeleccionadoId,
      skinId: _skinSeleccionadoId,
    );
  }
}