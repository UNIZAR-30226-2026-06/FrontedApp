import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/socket_service.dart';

import '../providers/auth_provider.dart';

import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/partida_repository.dart';

import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/partida_actual_viewmodel.dart';

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
    final apiService = ApiService();
    final authRepository = AuthRepository(apiService);
    final userRepository = UserRepository(apiService);
    final partidaRepository = PartidaRepository(apiService);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SocketService()),

        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            authRepository,
            context.read<SocketService>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (context) => PartidaActualViewModel(
            partidaRepository,
            context.read<SocketService>(),
          ),
        ),

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