class UsuarioModel {
  final String nombreUsuario;
  final String correo;
  final int monedas;
  final int totalGanadas;
  final int totalPartidas;
  final int? idAvatarSeleccionado;
  final int? idEstiloSeleccionado;
  final String? token;
  final List<int> avataresComprados;
  final List<int> estilosComprados;

  UsuarioModel({
    required this.nombreUsuario,
    required this.correo,
    this.monedas = 0,
    this.totalGanadas = 0,
    this.totalPartidas = 0,
    this.idAvatarSeleccionado,
    this.idEstiloSeleccionado,
    this.token,
    this.avataresComprados = const [],
    this.estilosComprados = const [],
  });

  // Método empleado para actualizar datos del usuario
  UsuarioModel copyWith({
    String? nombreUsuario,
    String? correo,
    int? monedas,
    int? totalGanadas,
    int? totalPartidas,
    int? idAvatarSeleccionado,
    int? idEstiloSeleccionado,
    String? token,
    List<int>? avataresComprados,
    List<int>? estilosComprados,
  }) {
    return UsuarioModel(
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      correo: correo ?? this.correo,
      monedas: monedas ?? this.monedas,
      totalGanadas: totalGanadas ?? this.totalGanadas,
      totalPartidas: totalPartidas ?? this.totalPartidas,
      idAvatarSeleccionado: idAvatarSeleccionado ?? this.idAvatarSeleccionado,
      idEstiloSeleccionado: idEstiloSeleccionado ?? this.idEstiloSeleccionado,
      token: token ?? this.token,
      avataresComprados: avataresComprados ?? this.avataresComprados,
      estilosComprados: estilosComprados ?? this.estilosComprados,
    );
  }

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
      avataresComprados: json['avatares_comprados'] != null
          ? List<int>.from(json['avatares_comprados'])
          : [],
      estilosComprados: json['estilos_comprados'] != null
        ? List<int>.from(json['estilos_comprados'])
          : []
    );
  }

  // Se usa principalmente para el registro o actualización
  Map<String, dynamic> toJson({String? password}) {
    return {
      'nombre_usuario': nombreUsuario,
      'correo': correo,
      'id_avatar_seleccionado': idAvatarSeleccionado,
      'id_estilo_seleccionado': idEstiloSeleccionado,
      'avatares_comprados': avataresComprados,
      'estilos_comprados' : estilosComprados,
      if (password != null) 'password': password,
    };
  }

  //Tengo mis dudas si modificar los datos devueltos
  @override
  String toString() => 'Usuario(nombre: $nombreUsuario, correo: $correo, monedas: $monedas)';
}