import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Live network reachability (Wi‑Fi / mobile / none). Not a guarantee the API is up.
class DashboardConnectivityChip extends StatefulWidget {
  const DashboardConnectivityChip({super.key});

  @override
  State<DashboardConnectivityChip> createState() => _DashboardConnectivityChipState();
}

class _DashboardConnectivityChipState extends State<DashboardConnectivityChip> {
  List<ConnectivityResult> _results = const [ConnectivityResult.none];
  StreamSubscription<List<ConnectivityResult>>? _sub;

  @override
  void initState() {
    super.initState();
    _bind();
  }

  Future<void> _bind() async {
    try {
      final initial = await Connectivity().checkConnectivity();
      if (mounted) setState(() => _results = initial);
    } catch (_) {
      if (mounted) setState(() => _results = const [ConnectivityResult.none]);
    }
    _sub = Connectivity().onConnectivityChanged.listen((r) {
      if (mounted) setState(() => _results = r);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  bool get _online => _results.any((e) => e != ConnectivityResult.none);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final online = _online;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Tooltip(
        message: online
            ? 'Device has a network interface. Server may still be unreachable.'
            : 'No network connection detected.',
        child: Chip(
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          avatar: Icon(
            online ? Icons.wifi : Icons.wifi_off,
            size: 16,
            color: online ? scheme.primary : scheme.outline,
          ),
          label: Text(
            online ? 'Online' : 'Offline',
            style: textTheme.labelSmall?.copyWith(
              color: online ? scheme.onSurface : scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          side: BorderSide(color: scheme.outline.withOpacity(0.35)),
          backgroundColor: online ? scheme.surfaceContainerHighest : scheme.surfaceContainerHigh,
        ),
      ),
    );
  }
}
