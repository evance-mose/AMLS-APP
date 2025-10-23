import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubits/auth/auth_cubit.dart';
import 'cubits/home/home_cubit.dart';
import 'cubits/issues/issue_cubit.dart';
import 'cubits/logs/log_cubit.dart';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()),
        BlocProvider(create: (context) => LogCubit()),
        BlocProvider(create: (context) => IssueCubit()),
        BlocProvider(create: (context) => HomeCubit()),
      ],
      child: MaterialApp(
        title: 'AMLS',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.grey,
            primary: Colors.black,
            onPrimary: Colors.white,
            primaryContainer: Colors.grey.shade200,
            onPrimaryContainer: Colors.black87,
            secondary: Colors.grey.shade800,
            onSecondary: Colors.white,
            secondaryContainer: Colors.grey.shade300,
            onSecondaryContainer: Colors.black87,
            tertiary: Colors.blueGrey,
            onTertiary: Colors.white,
            tertiaryContainer: Colors.blueGrey.shade100,
            onTertiaryContainer: Colors.blueGrey.shade900,
            error: Colors.red.shade700,
            onError: Colors.white,
            errorContainer: Colors.red.shade100,
            onErrorContainer: Colors.red.shade900,
            background: Colors.white,
            onBackground: Colors.black87,
            surface: Colors.white,
            onSurface: Colors.black87,
            surfaceVariant: Colors.grey.shade100,
            onSurfaceVariant: Colors.grey.shade700,
            outline: Colors.grey.shade300,
            shadow: Colors.black,
            inverseSurface: Colors.black87,
            onInverseSurface: Colors.white,
            inversePrimary: Colors.grey.shade400,
            surfaceTint: Colors.black,
          ),
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
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (state is AuthAuthenticated) {
              return const HomePage();
            } else {
              return const LoginPage();
            }
          },
        ),
        routes: {
          '/logs': (context) => const MaintenanceLogsScreen(),
          '/issues': (context) => const IssuesScreen(),
        },
      ),
    );
  }
}
