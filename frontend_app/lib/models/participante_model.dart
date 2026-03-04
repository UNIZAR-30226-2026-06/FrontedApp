import 'jugador_model.dart';
import 'package:frontend_app/models/carta_model.dart';

class Participante {
  final Jugador perfil;
  List<Carta> mano;
  bool esSuTurno;
  bool haDichoUno;
  int posicionEnMesa;

  Participante({
    required this.perfil,
    List<Carta>? mano,
    this.esSuTurno = false,
    this.haDichoUno = false,
    this.posicionEnMesa = 0,
  }) : this.mano = mano ?? [];

  int get cantidadCartas => mano.length;

  factory Participante.bot(int idBot, {int posicion = 0}) {
    return Participante(
      perfil: Jugador(
        nombre: "Bot $idBot",
        coins: 0,
        avatarId: "imagenBot",
        skinId: "default",
      ),
      posicionEnMesa: posicion,
    );
  }
}