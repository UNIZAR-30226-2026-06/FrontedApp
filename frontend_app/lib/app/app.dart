import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';

// Importación de ViewModels
import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';

// Importación de Vistas
import '../views/login_view.dart';
import '../views/home_view.dart';
import '../views/registro_view.dart';
import '../views/tienda_view.dart';
import '../views/amigos_view.dart';
import '../views/recuperarPassword_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Instanciamos la base de la pirámide (Solo una vez para toda la app)
    final apiService = ApiService();
    final authRepository = AuthRepository(apiService);
    final userRepository = UserRepository(apiService);

    return MultiProvider(
      providers: [
        // 2. Inyectamos el AuthProvider que gestionará el estado global de la sesión
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepository)),

        // 3. Registramos los ViewModels pasando las dependencias necesarias
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel(userRepo: userRepository)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NOT UNO',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFF2D3473),
          useMaterial3: true,
        ),
        home: const LoginView(),
        routes: {
          '/login': (context) => const LoginView(),
          '/registro': (context) => const RegistroView(),
          '/home': (context) => const HomeView(),
          '/tienda': (context) => const TiendaView(),
          '/amigos': (context) => const AmigosView(),
          '/recuperar': (context) => const RecuperarPasswordView(),
        },
      ),
    );
  }
}
