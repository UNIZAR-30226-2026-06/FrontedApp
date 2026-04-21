import 'package:flutter/material.dart';
import '../models/tienda_item_model.dart';
import '../repositories/tienda_repository.dart';

enum TiendaFiltro { todos, avatares, disenos }

class TiendaViewModel extends ChangeNotifier {
  final TiendaRepository repo;

  TiendaViewModel({required this.repo}) {
    cargarTienda();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<TiendaItem> _items = [];

  TiendaFiltro _filtro = TiendaFiltro.todos;
  TiendaFiltro get filtro => _filtro;

  void setFiltro(TiendaFiltro nuevo) {
    _filtro = nuevo;
    notifyListeners();
  }

  /// Carga los datos reales del servidor
  Future<void> cargarTienda() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Pedimos los avatares y estilos reales al repositorio
      _items = await repo.obtenerCatalogoCompleto();
    } catch (e) {
      debugPrint("Error cargando catálogo: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<TiendaItem> get itemsFiltrados {
    switch (_filtro) {
      case TiendaFiltro.todos:
        return _items;
      case TiendaFiltro.avatares:
        return _items.where((i) => i.tipo == TiendaItemTipo.avatar).toList();
      case TiendaFiltro.disenos:
        return _items.where((i) => i.tipo == TiendaItemTipo.diseno).toList();
    }
  }

  Future<int> ejecutarCompra(TiendaItem item) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Como ahora el item viene de la base de datos, el item.id ya es el correcto
      int idReal = int.parse(item.id);
      int nuevoSaldo;

      if (item.tipo == TiendaItemTipo.avatar) {
        nuevoSaldo = await repo.comprarAvatar(idReal);
      } else {
        nuevoSaldo = await repo.comprarEstilo(idReal);
      }

      _isLoading = false;
      notifyListeners();
      return nuevoSaldo;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}