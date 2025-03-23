// File: lib/main.dart

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const BetaChinApp());
}

class BetaChinApp extends StatelessWidget {
  const BetaChinApp({super.key}); // Updated to use super parameter

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BetaChin Real Estate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const HomeScreen(),
      // Suggestion: Add a splash screen or initial route for better UX
      // initialRoute: '/splash',
      // routes: {
      //   '/splash': (context) => SplashScreen(),
      //   '/home': (context) => HomeScreen(),
      // },
    );
  }
}
