import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/reservation_screen.dart';



const String kBaseUrl = 'http://localhost:3000';

const String kAuthToken = '';

void main() {
  runApp(const NoirEtSableApp());
}

class NoirEtSableApp extends StatelessWidget {
  const NoirEtSableApp({super.key});

  @override
  Widget build(BuildContext context) {
    const beige = Color(0xFFF4E9DC);
    const noir = Color(0xFF111111);

    return MaterialApp(
      title: 'Noir & Sable',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: beige,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB88958), 
          background: beige,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: beige,
          foregroundColor: noir,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: noir,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: const HomeScreen(),
      routes: {
        '/reservation': (context) => const ReservationPage(
              authToken: kAuthToken,
              baseUrl: kBaseUrl,
            ),
      },
    );
  }
}
