class UsuarioModel {
  final String nombreUsuario;
  final String correo;
  final int monedas;
  final int totalGanadas;
  final int totalPartidas;
  final int? idAvatarSeleccionado;
  final int? idEstiloSeleccionado;
  final String? token;

  UsuarioModel({
    required this.nombreUsuario,
    required this.correo,
    this.monedas = 0,
    this.totalGanadas = 0,
    this.totalPartidas = 0,
    this.idAvatarSeleccionado,
    this.idEstiloSeleccionado,
    this.token,
  });


  factory UsuarioModel.fromJson(Map<String, dynamic> json, {required token}) {
    return UsuarioModel(
      nombreUsuario: json['nombre_usuario'] ?? '',
      correo: json['correo'] ?? '',
      monedas: json['monedas'] ?? 0,
      totalGanadas: json['total_ganadas'] ?? 0,
      totalPartidas: json['total_partidas'] ?? 0,
      idAvatarSeleccionado: json['id_avatar_seleccionado'] ?? json['avatar'],
      idEstiloSeleccionado: json['id_estilo_seleccionado'] ?? json['estilo'],
      token: token,
    );
  }

  // Se usa principalmente para el registro o actualización
  Map<String, dynamic> toJson({String? password}) {
    return {
      'nombre_usuario': nombreUsuario,
      'correo': correo,
      if (password != null) 'password': password, // El campo se llama 'password' en la API
    };
  }

  @override
  String toString() => 'Usuario(nombre: $nombreUsuario, correo: $correo, monedas: $monedas)';
}