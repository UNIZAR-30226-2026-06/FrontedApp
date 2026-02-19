import 'package:flutter/material.dart';
import '../screens/home_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Frontend App',
      home: const HomeScreen(
        playerName: 'Jugador1',
        coins: 500,
      ),
    );
  }
}