import 'package:flutter/material.dart';
import 'package:batallas_pokemon/vistas/seleccion_equipo.dart';

void main() {
  runApp(const BatallaApp());
}


const Color pastelBackground = Color(0xFFE0F7FA);
const Color pastelWhite = Color(0xFFFFFFFF);
const Color pastelBlue = Color(0xFFBBDEFB);
const Color pastelGreen = Color(0xFFA5D6A7);
const Color pastelYellow = Color(0xFFFFECB3);
const Color pastelOrange = Color(0xFFFFCC80);
const Color pastelPink = Color(0xFFF8BBD0);
const Color primaryButtonColor = Color(0xFFFFA726);

class BatallaApp extends StatelessWidget {
  const BatallaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '¡Batalla POKEMON!',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: pastelBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: pastelBlue,
          foregroundColor: Colors.black87,
          elevation: 4,
        ),
        cardTheme: CardThemeData(
          color: pastelWhite,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryButtonColor,
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
      home: const SeleccionEquipo(),
    );
  }
}