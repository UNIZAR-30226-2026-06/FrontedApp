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
      _usuario = await _repository.login(email, password);
      if (_usuario != null) {
        await cargarInventarioCompleto();
      }
    } catch (e) {
      _usuario = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cargarInventarioCompleto() async {
    if (_usuario == null) return;

    try {
      final resultados = await Future.wait([
        _repository.obtenerAvataresComprados(),
        _repository.obtenerEstilosComprados(),
      ]);

      _usuario = _usuario!.copyWith(
        avataresComprados: resultados[0],
        estilosComprados: resultados[1],
      );

      notifyListeners();
      print("Inventario cargado exitosamente: ${_usuario!.avataresComprados}");
    } catch (e) {
      debugPrint("Error al cargar inventario: $e");
    }
  }

  void actualizarMonedas(int nuevaCantidad) {
    if (_usuario != null) {
      _usuario = _usuario!.copyWith(monedas: nuevaCantidad);
      notifyListeners();
    }
  }

  void registrarCompraExitosa(int idComprado, int nuevoSaldo, {required bool esAvatar}) {
    if (_usuario == null) return;

    final listaActual = esAvatar ? _usuario!.avataresComprados : _usuario!.estilosComprados;
    final nuevaLista = {...listaActual, idComprado}.toList();

    _usuario = esAvatar
        ? _usuario!.copyWith(avataresComprados: nuevaLista)
        : _usuario!.copyWith(estilosComprados: nuevaLista);

    actualizarMonedas(nuevoSaldo);
  }
}