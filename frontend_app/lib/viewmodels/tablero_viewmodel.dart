import 'dart:math'; // Para barajar
import 'package:flutter/material.dart';
import '../models/jugador_model.dart';
import '../models/participante_model.dart';
import '../models/carta_model.dart';

class TableroViewModel extends ChangeNotifier {
  Participante? jugadorHumano;
  List<Participante> bots = [];

  // --- NUEVOS ELEMENTOS DEL ESTADO ---
  List<Carta> mazo = [];
  Carta? cartaActual;
  int turnoIndex = 0;
  bool _mostrandoAjustes = false;

  bool get mostrandoAjustes => _mostrandoAjustes;

  void prepararPartida(Jugador miPerfil) {
    // 1. Inicializar participantes
    jugadorHumano = Participante(perfil: miPerfil, posicionEnMesa: 0);
    bots = [
      Participante.bot(1, posicion: 1),
      Participante.bot(2, posicion: 2),
      Participante.bot(3, posicion: 3),
    ];

    // 2. Generar y barajar el mazo
    _crearMazo();

    // 3. Repartir cartas iniciales (7 a cada uno como en el UNO)
    _repartirIniciales();

    // 4. Poner la primera carta en la mesa
    cartaActual = mazo.removeLast();

    notifyListeners(); // Avisamos a la View para que pinte todo
  }

  // --- LÓGICA DE JUEGO (MÉTODOS PRIVADOS) ---

  void _crearMazo() {
    mazo = [];
    // Ejemplo rápido: crear cartas por cada color
    for (var color in CartaColor.values) {
      if (color == CartaColor.especial) continue;
      for (var valor in CartaValor.values) {
        if (valor.index <= 9) { // Solo números para empezar
          mazo.add(Carta(color: color, valor: valor, id: Random().nextDouble().toString()));
        }
      }
    }
    mazo.shuffle(); // Barajar (el Collections.shuffle de Java)
  }

  void _repartirIniciales() {
    for (int i = 0; i < 7; i++) {
      jugadorHumano?.mano.add(mazo.removeLast());
      for (var bot in bots) {
        bot.mano.add(mazo.removeLast());
      }
    }
  }

  // --- ACCIONES DEL USUARIO ---

  void robarCarta() {
    if (mazo.isNotEmpty) {
      jugadorHumano?.mano.add(mazo.removeLast());
      notifyListeners();
      // Aquí podrías disparar el turno del siguiente
    }
  }

  void abrirAjustes() {
    _mostrandoAjustes = true;
    notifyListeners();
  }

  void cerrarAjustes() {
    _mostrandoAjustes = false;
    notifyListeners();
  }

  void intentarTirarCarta(Carta carta) {
    // Lógica de validación (ej: mismo color o mismo valor)
    if (carta.color == cartaActual?.color || carta.valor == cartaActual?.valor) {
      cartaActual = carta;
      jugadorHumano?.mano.remove(carta);
      notifyListeners();
      debugPrint("Carta lanzada: ${carta.valor} ${carta.color}");
    } else {
      debugPrint("Jugada no válida");
    }
  }
}