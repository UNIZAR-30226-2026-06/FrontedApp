import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';
import '../models/usuario_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _repository;
  UsuarioModel? _usuario;
  bool _isLoading = false;

  AuthProvider(this._repository);

  UsuarioModel? get usuario => _usuario;
  bool get isLoading => _isLoading;

  Future<void> register(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _usuario = await _repository.register(username, email, password);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Llamamos al repositorio para validar contra el backend
      _usuario = await _repository.login(email, password);
      notifyListeners();
    } catch (e) {
      _usuario = null;
      rethrow; // Lanzamos el error para que el ViewModel lo capture
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}