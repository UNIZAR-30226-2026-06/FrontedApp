import 'package:flutter/material.dart';
import '../models/jugador_model.dart';
import '../repositories/amigos_repository.dart';

enum AmigosTab { misAmigos, buscar, solicitudes }

class AmigosViewModel extends ChangeNotifier {
  final AmigosRepository _repo;

  bool isLoading = false;
  String errorMessage = '';

  List<Jugador> misAmigos = [];
  List<Map<String, dynamic>> solicitudes = [];
  List<Jugador> resultadosBusqueda = [];

  AmigosTab _tab = AmigosTab.misAmigos;
  AmigosTab get tab => _tab;

  final TextEditingController searchController = TextEditingController();

  AmigosViewModel({required AmigosRepository repo}) : _repo = repo {
    _inicializar();
  }

  Future<void> _inicializar() async {
    _setLoading(true);
    try {
      await Future.wait([
        _cargarAmigos(),
        _cargarSolicitudes(),
      ]);
    } catch (e) {
      errorMessage = "Error al conectar con el servidor.";
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _cargarAmigos() async {
    misAmigos = await _repo.fetchAmigos();
  }

  Future<void> _cargarSolicitudes() async {
    solicitudes = await _repo.fetchSolicitudes();
  }

  void setTab(AmigosTab t) {
    if (_tab == t) return;
    _tab = t;

    if (_tab != AmigosTab.buscar) {
      searchController.clear();
      resultadosBusqueda.clear();
    }
    notifyListeners();
  }

  Future<void> buscarUsuarios() async {
    final query = searchController.text.trim();
    if (query.isEmpty) {
      resultadosBusqueda.clear();
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      resultadosBusqueda = await _repo.buscarUsuarios(query);
    } catch (e) {
      errorMessage = "Error en la búsqueda.";
      resultadosBusqueda = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> eliminarAmigo(String userId) async {
    try {
      await _repo.eliminarAmigo(userId);
      misAmigos.removeWhere((u) => u.nombre == userId);
      notifyListeners();
    } catch (e) {
      debugPrint("Error al eliminar amigo: $e");
    }
  }

  Future<void> enviarSolicitud(String emailOCodigo) async {
    try {
      await _repo.enviarSolicitud(emailOCodigo);
    } catch (e) {
      debugPrint("Error al enviar solicitud: $e");
    }
  }

  Future<void> responderSolicitud(String solicitudId, bool aceptar) async {
    try {
      await _repo.responderSolicitud(solicitudId, aceptar);
      await _inicializar();
    } catch (e) {
      debugPrint("Error al responder solicitud: $e");
    }
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}