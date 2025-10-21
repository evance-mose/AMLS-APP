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
