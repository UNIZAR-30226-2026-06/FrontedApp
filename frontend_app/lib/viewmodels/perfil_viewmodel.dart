import 'package:flutter/material.dart';
import '../models/jugador_model.dart';
import '../models/perfil_models.dart';

class PerfilViewModel extends ChangeNotifier {
  PerfilViewModel({Jugador? jugadorInicial})
      : _nombre = jugadorInicial?.nombre ?? "Jugador",
        _coins = jugadorInicial?.coins ?? 0,
        _avatarSeleccionadoId = jugadorInicial?.avatarId ?? 'a0',
        _skinSeleccionadoId = jugadorInicial?.skinId ?? 's1' {

    _initLists(); // Extraemos la inicialización para limpiar el constructor
    _validateSelection();
  }

  void _initLists() {
    _avatars = const [
      AvatarItem(id: 'a0', emoji: '👤', nombre: 'Default'),
      AvatarItem(id: 'a1', emoji: '🤖', nombre: 'Robot'),
      AvatarItem(id: 'a2', emoji: '🤠', nombre: 'Cowboy'),
      AvatarItem(id: 'a3', emoji: '😈', nombre: 'Diablillo'),
    ];
    _skins = const [
      CardSkinItem(id: 's1', nombre: 'Classic', emoji: '🃏'),
      CardSkinItem(id: 's2', nombre: 'Neón', emoji: '✨'),
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
  int _coins;

  String get nombre => _nombre;
  int get coins => _coins;

  late final List<AvatarItem> _avatars;
  late final List<CardSkinItem> _skins;

  List<AvatarItem> get avatars => _avatars;
  List<CardSkinItem> get skins => _skins;

  // ✅ Selecciones persistentes
  String _avatarSeleccionadoId;
  String _skinSeleccionadoId;

  String get avatarSeleccionadoId => _avatarSeleccionadoId;
  String get skinSeleccionadoId => _skinSeleccionadoId;

  AvatarItem get avatarSeleccionado =>
      _avatars.firstWhere((a) => a.id == _avatarSeleccionadoId);

  CardSkinItem get skinSeleccionado =>
      _skins.firstWhere((s) => s.id == _skinSeleccionadoId);

  void seleccionarAvatar(String id) {
    _avatarSeleccionadoId = id;
    notifyListeners();
  }

  void seleccionarSkin(String id) {
    _skinSeleccionadoId = id;
    notifyListeners();
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
      coins: _coins,
      avatarId: _avatarSeleccionadoId,
      skinId: _skinSeleccionadoId,
    );
  }
}