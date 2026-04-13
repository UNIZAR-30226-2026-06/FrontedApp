import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';

void main() {
  //Lanzamiento de la App
  runApp(const MyApp());
}

/*
Para que el cambio sea instantáneo cuando tengas tu API, he hecho lo siguiente:
1.Archivo de Configuración Global (lib/app/api_config.dart): He creado este archivo donde he centralizado todas las URLs.
Cuando tengas tu backend real, solo tendrás que cambiar la baseUrl en este único sitio y toda la app (Login, Tienda, Perfil, Amigos) se conectará automáticamente al nuevo servidor.

2.Capa de Repositorios desacoplada: He dejado los repositorios (UserRepository, AuthRepository, AmigosRepository)
preparados con los métodos GET, POST, PUT y DELETE estándar. Así, si tu API cambia ligeramente los nombres de los campos,
solo tendrás que tocar el repositorio correspondiente, no las vistas ni los ViewModels.

3.Bypass de Errores: He añadido un sistema de "Silent Failure" en los ViewModels. Si la API aún no existe o el servidor está apagado,
la app imprimirá un error en la consola (debugPrint) pero seguirá funcionando localmente, para que no se te bloquee el desarrollo del Front-end.

Cuando tengas tu API lista, solo tendrás que:
1.Poner la IP de tu servidor en api_config.dart.
2.Asegurarte de que los nombres de los campos en el fromJson de tus modelos coincidan con lo que devuelve tu base de datos.
 */