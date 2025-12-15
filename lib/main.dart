// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state/auth_model.dart';
import 'screens/login_screen.dart'; 
import 'screens/account_room_screen.dart'; 

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthModel(),
      child: const BankingApp(),
    ),
  );
}

class BankingApp extends StatelessWidget {
  const BankingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Banking Companion',
      debugShowCheckedModeBanner: false,

      // Apply Material 3 Theme
      theme: ThemeData(
        useMaterial3: true,
        // Set the brand seed color (Cyan based on your old CSS)
        colorSchemeSeed: Colors.cyan[600], 
        brightness: Brightness.light, 
      ),

      // Watch the authentication state to route the user
      home: Consumer<AuthModel>(
        builder: (context, authModel, child) {
          if (authModel.isAuthenticated) {
            return const AccountRoomScreen(); 
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}