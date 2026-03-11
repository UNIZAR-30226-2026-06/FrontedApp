import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importación de ViewModels
import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';

// Importación de Vistas
import '../views/login_view.dart';
import '../views/home_view.dart';
import '../views/registro_view.dart';
import '../views/tienda_view.dart';
import '../views/amigos_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Aquí registramos los ViewModels para que estén disponibles en toda la App
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        // Puedes ir añadiendo el resto de ViewModels según los conectes al Back
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NOT UNO',

        // Tema visual acorde a tu diseño de Figma
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFF2D3473),
          useMaterial3: true,
        ),

        // Definimos la pantalla de inicio como el Login
        home: const LoginView(),

        // Tabla de rutas para navegación centralizada
        routes: {
          '/login': (context) => const LoginView(),
          '/registro': (context) => const RegistroView(),
          '/home': (context) => const HomeView(),
          '/tienda': (context) => const TiendaView(),
          '/amigos': (context) => const AmigosView(),
        },
      ),
    );
  }
}