import 'package:flutter/material.dart';
import '../models/jugador_model.dart';
import '../models/tienda_item_model.dart';

enum TiendaFiltro { todos, avatares, disenos }

class TiendaViewModel extends ChangeNotifier {
  // Constructor: Inicializa el jugador (con monedas para pruebas) y el catálogo
  TiendaViewModel({Jugador? jugador})
      : _jugador = jugador ?? Jugador(
      nombre: "Invitado",
      coins: 1000, // Saldo inicial para testear compras
      avatarId: 'a0',
      skinId: 's1'
  ) {
    _items = _seedItems(); // Carga el dataset de productos
  }

  // Estado del jugador (Privado para control de cambios mediante notifyListeners)
  Jugador _jugador;
  Jugador get jugador => _jugador;

  // Lista interna de productos de la tienda
  late final List<TiendaItem> _items;

  // Gestión de filtros de la interfaz
  TiendaFiltro _filtro = TiendaFiltro.todos;
  TiendaFiltro get filtro => _filtro;

  /// Cambia la pestaña activa de la tienda y actualiza la UI
  void setFiltro(TiendaFiltro nuevo) {
    _filtro = nuevo;
    notifyListeners();
  }

  /// Devuelve los artículos filtrados según la pestaña seleccionada
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

  /// Lógica de negocio para ejecutar la compra (Invocada tras la confirmación del diálogo)
  /// Devuelve [true] si el jugador tenía saldo suficiente y la compra se realizó.
  bool ejecutarCompra(TiendaItem item) {
    if (_jugador.coins >= item.precio) {
      // Actualizamos el estado del jugador de forma inmutable
      _jugador = _jugador.copyWith(
        coins: _jugador.coins - item.precio,
      );

      // En la Fase 2, aquí se añadiría la lógica de persistencia con el servidor (API)

      notifyListeners(); // Notifica a la View para actualizar el contador de monedas
      return true;
    }

    // Saldo insuficiente
    return false;
  }

  /// Catálogo de productos inicial (Hitos y recursos del proyecto)
  List<TiendaItem> _seedItems() {
    return const [
      TiendaItem(
        id: 'a1',
        titulo: 'Avatar Robot',
        precio: 100,
        tipo: TiendaItemTipo.avatar,
        assetPath: 'assets/images/shop/robot.png',
      ),
      TiendaItem(
        id: 'a2',
        titulo: 'Avatar Alien',
        precio: 300,
        tipo: TiendaItemTipo.avatar,
        assetPath: 'assets/images/shop/alien.png',
      ),
      TiendaItem(
        id: 'a3',
        titulo: 'Avatar Ninja',
        precio: 200,
        tipo: TiendaItemTipo.avatar,
        assetPath: 'assets/images/shop/ninja.png',
      ),
      TiendaItem(
        id: 'a4',
        titulo: 'Avatar Caballero',
        precio: 250,
        tipo: TiendaItemTipo.avatar,
        assetPath: 'assets/images/shop/knight.png',
      ),
      TiendaItem(
        id: 'd1',
        titulo: 'Diseño Dorado',
        precio: 400,
        tipo: TiendaItemTipo.diseno,
        assetPath: 'assets/images/shop/gold.png',
      ),
      TiendaItem(
        id: 'd2',
        titulo: 'Diseño Espacial',
        precio: 500,
        tipo: TiendaItemTipo.diseno,
        assetPath: 'assets/images/shop/space.png',
      ),
      TiendaItem(
        id: 'd3',
        titulo: 'Diseño Neón',
        precio: 350,
        tipo: TiendaItemTipo.diseno,
        assetPath: 'assets/images/shop/neon.png',
      ),
      TiendaItem(
        id: 'd4',
        titulo: 'Diseño Retro',
        precio: 150,
        tipo: TiendaItemTipo.diseno,
        assetPath: 'assets/images/shop/retro.png',
      ),
    ];
  }
}