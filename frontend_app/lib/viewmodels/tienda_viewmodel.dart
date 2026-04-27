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

  // Lista de IDs que el usuario ya posee (Viene del AuthProvider)
  List<int> _itemsComprados = [];

  void setFiltro(TiendaFiltro nuevo) {
    _filtro = nuevo;
    notifyListeners();
  }

  // Actualiza la lista de propiedad del usuario y refresca la vista
  void actualizarInventario(List<int> listaIds) {
    if (_itemsComprados.length == listaIds.length &&
        _itemsComprados.every((id) => listaIds.contains(id))) {
      return;
    }
    _itemsComprados = listaIds;
    print("🛠️ Inventario actualizado en el VM: $_itemsComprados"); //BORRAR
    notifyListeners();
  }

  Future<void> cargarTienda() async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await repo.obtenerCatalogoCompleto();
    } catch (e) {
      debugPrint("Error cargando catálogo: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<TiendaItem> get itemsFiltrados {

    print("🔍 IDs en la mochila del usuario: $_itemsComprados"); //BORRAR
    Iterable<TiendaItem> filtrados;

    switch (_filtro) {
      case TiendaFiltro.todos:
        filtrados = _items;
        break;
      case TiendaFiltro.avatares:
        filtrados = _items.where((i) => i.tipo == TiendaItemTipo.avatar);
        break;
      case TiendaFiltro.disenos:
        filtrados = _items.where((i) => i.tipo == TiendaItemTipo.diseno);
        break;
    }


    return filtrados.where((item) {
      final idNumerico = int.tryParse(item.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? -1;
      return !_itemsComprados.contains(idNumerico);
    }).toList();
  }

  Future<int> ejecutarCompra(TiendaItem item) async {
    _isLoading = true;
    notifyListeners();

    try {
      int idReal = int.parse(item.id.replaceAll(RegExp(r'[^0-9]'), ''));
      int nuevoSaldo;

      if (item.tipo == TiendaItemTipo.avatar) {
        nuevoSaldo = await repo.comprarAvatar(idReal);
      } else {
        nuevoSaldo = await repo.comprarEstilo(idReal);
      }

      // No actualizamos el inventario aquí directamente,
      // dejamos que el AuthProvider lo haga para mantener la "Fuente de la Verdad"
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