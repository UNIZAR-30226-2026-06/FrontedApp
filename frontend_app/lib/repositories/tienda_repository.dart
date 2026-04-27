import 'dart:convert';
import '../services/api_service.dart';
import '../models/tienda_item_model.dart';

class TiendaRepository {
  final ApiService _api;

  TiendaRepository(this._api);

  Future<int> comprarAvatar(int avatarId) async {
    final response = await _api.post(
        '/wallet/purchase/avatar',
        {'id_avatar': avatarId}
    );
    return _gestionarRespuesta(response);
  }

  Future<int> comprarEstilo(int estiloId) async {
    final response = await _api.post(
        '/wallet/purchase/estilo',
        {'id_estilo': estiloId}
    );
    return _gestionarRespuesta(response);
  }


  int _gestionarRespuesta(dynamic response) {
    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body);
    } catch (e) {
      throw Exception('El servidor respondió con un formato inválido.');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final nuevoSaldo = data['coins'] ?? data['nuevo_balance'] ?? data['monedas'];

      if (nuevoSaldo == null) {
        throw Exception('Compra exitosa, pero no se recibió el nuevo saldo.');
      }

      return int.tryParse(nuevoSaldo.toString()) ?? 0;
    }

    else {
      final mensajeError = data['error'] ?? data['message'] ?? 'Error desconocido en la transacción';
      throw Exception(mensajeError);
    }
  }

  Future<List<TiendaItem>> obtenerCatalogoCompleto() async {
    final resAvatares = await _api.get('/store/avatars');
    final resEstilos = await _api.get('/store/estilos');

    List<TiendaItem> todos = [];

    if (resAvatares.statusCode == 200) {
      final List<dynamic> data = jsonDecode(resAvatares.body);
      todos.addAll(data.map((json) => TiendaItem(
        id: json['id_avatar'].toString(),
        titulo: json['nombre'] ?? 'Avatar',
        precio: json['precioavatar'] ?? 0,
        tipo: TiendaItemTipo.avatar,
        assetPath: json['image'],
      )));
    }

    if (resEstilos.statusCode == 200) {
      final List<dynamic> data = jsonDecode(resEstilos.body);
      todos.addAll(data.map((json) => TiendaItem(
        id: json['id_estilo'].toString(),
        titulo: json['nombre'] ?? 'Diseño',
        precio: json['precioestilo'] ?? 0,
        tipo: TiendaItemTipo.diseno,
        assetPath: json['image'],
      )));
    }

    return todos;
  }

}
