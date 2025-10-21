import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubits/auth/auth_cubit.dart';
import 'home_page.dart';
import 'issues_page.dart';
import 'login_page.dart';
import 'logs_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: MaterialApp(
        title: 'AMLS',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.black87),
          useMaterial3: true,
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontSize: 96, fontWeight: FontWeight.bold, color: Colors.black87),
            displayMedium: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.black87),
            displaySmall: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black87),
            headlineLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black87),
            headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
            headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
            titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
            bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black87),
            bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black87),
            bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.black87),
            labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
            labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
        initialRoute: '/login', // or '/login' if you want to start at login
        routes: {
          '/home': (context) => const HomePage(),
          '/logs': (context) => const MaintenanceLogsScreen(),
          '/issues': (context) => const IssuesScreen(),
          '/login': (context) => const LoginPage(),
        },
      ),
    );
  }
}
