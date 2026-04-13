import 'package:amls/cubits/auth/auth_cubit.dart';
import 'package:amls/models/user_model.dart';
import 'package:amls/services/location_trail_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Technician-only settings (e.g. location trail).
class TechnicianSettingsPage extends StatefulWidget {
  const TechnicianSettingsPage({super.key});

  @override
  State<TechnicianSettingsPage> createState() => _TechnicianSettingsPageState();
}

class _TechnicianSettingsPageState extends State<TechnicianSettingsPage> {
  bool _trailEnabled = false;
  bool _trailToggling = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final e = await LocationTrailService.instance.enabled;
      if (mounted) setState(() => _trailEnabled = e);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    if (authState is! AuthAuthenticated || authState.user?.role != UserRole.technician) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access denied')),
        body: const Center(child: Text('Technician settings are only available to technicians.')),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.arrow_back, color: colorScheme.onSurface, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Location',
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    secondary: Icon(Icons.route_outlined, color: colorScheme.primary),
                    title: Text(
                      'Location trail',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      'Sends your GPS about every 3 minutes while the app is open. Pauses when you leave the app.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                    value: _trailEnabled,
                    onChanged: _trailToggling
                        ? null
                        : (v) async {
                            setState(() => _trailToggling = true);
                            await LocationTrailService.instance.setEnabled(v);
                            final e = await LocationTrailService.instance.enabled;
                            if (!mounted) return;
                            setState(() {
                              _trailToggling = false;
                              _trailEnabled = e;
                            });
                            if (v && !e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Could not start trail. Turn on location services and allow location access.',
                                  ),
                                  backgroundColor: colorScheme.error,
                                ),
                              );
                            }
                          },
                  ),
                  ValueListenableBuilder<DateTime?>(
                    valueListenable: LocationTrailService.instance.lastSentAt,
                    builder: (context, last, _) {
                      if (last == null) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 64, right: 16, bottom: 12),
                          child: Text(
                            'No samples sent yet this session.',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }
                      final t =
                          '${last.hour.toString().padLeft(2, '0')}:${last.minute.toString().padLeft(2, '0')}';
                      return Padding(
                        padding: const EdgeInsets.only(left: 64, right: 16, bottom: 12),
                        child: Text(
                          'Last sample queued or sent at $t.',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
