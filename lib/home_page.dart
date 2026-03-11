import 'package:amls/cubits/auth/auth_cubit.dart';
import 'package:amls/models/user_model.dart';
import 'package:amls/admin_dashboard_page.dart';
import 'package:amls/custodian_dashboard_page.dart';
import 'package:amls/technician_dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    // Route to appropriate dashboard based on user role
    if (authState is AuthAuthenticated) {
      final userRole = authState.user?.role;

      switch (userRole) {
        case UserRole.admin:
          return const AdminDashboardPage();
        case UserRole.custodian:
          return const CustodianDashboardPage();
        case UserRole.technician:
          return const TechnicianDashboardPage();
        default:
          // Fallback to admin dashboard if role is not recognized
          return const AdminDashboardPage();
      }
    }

    // If not authenticated, show loading or error
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
