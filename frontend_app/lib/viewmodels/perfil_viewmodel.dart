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

    _initLists();
    _validateSelection();
    cargarPersonalizacion();
  }

  final UserRepository? _repo;

  void _initLists() {
    _avatars = const [
      AvatarItem(id: '0', emoji: '👤', nombre: 'Default'),
      AvatarItem(id: '1', emoji: '🤖', nombre: 'Robot'),
      AvatarItem(id: '2', emoji: '🤠', nombre: 'Cowboy'),
      AvatarItem(id: '3', emoji: '😈', nombre: 'Diablillo'),
    ];
    _skins = const [
      CardSkinItem(id: '1', nombre: 'Classic', emoji: '🃏'),
      CardSkinItem(id: '2', nombre: 'Neón', emoji: '✨'),
    ];
  }

  void _validateSelection() {
    if (!_avatars.any((a) => a.id == _avatarSeleccionadoId)) {
      _avatarSeleccionadoId = _avatars.first.id;
    }
    if (!_skins.any((s) => s.id == _skinSeleccionadoId)) {
      _skinSeleccionadoId = _skins.first.id;
    }
  }

  // Estado principal del jugador
  String _nombre;
  String _correo;
  int _coins;

  String get nombre => _nombre;
  int get coins => _coins;

  List<AvatarItem> _avatars = const [];
  List<CardSkinItem> _skins = const [];

  List<AvatarItem> get avatars => _avatars;
  List<CardSkinItem> get skins => _skins;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // ✅ Selecciones persistentes
  String _avatarSeleccionadoId;
  String _skinSeleccionadoId;

  String get avatarSeleccionadoId => _avatarSeleccionadoId;
  String get skinSeleccionadoId => _skinSeleccionadoId;

  AvatarItem get avatarSeleccionado =>
      _avatars.firstWhere((a) => a.id == _avatarSeleccionadoId);

  CardSkinItem get skinSeleccionado =>
      _skins.firstWhere((s) => s.id == _skinSeleccionadoId);

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

      if (avatares.isNotEmpty) {
        _avatars = avatares.map((item) {
          return AvatarItem(
            id: item.id,
            emoji: '👤',
            nombre: item.titulo,
            assetPath: item.assetPath,
          );
        }).toList();
      }

      if (estilos.isNotEmpty) {
        _skins = estilos.map((item) {
          return CardSkinItem(
            id: item.id,
            nombre: item.titulo,
            emoji: '🃏',
            assetPath: item.assetPath,
          );
        }).toList();
      }

      _validateSelection();
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

  /// ✅ Devuelve el Jugador actualizado al Home
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
