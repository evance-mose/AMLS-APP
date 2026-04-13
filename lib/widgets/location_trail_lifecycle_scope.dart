import 'package:amls/services/location_trail_service.dart';
import 'package:flutter/widgets.dart';

/// Forwards app lifecycle to [LocationTrailService] (pause/resume periodic sampling).
class LocationTrailLifecycleScope extends StatefulWidget {
  const LocationTrailLifecycleScope({super.key, required this.child});

  final Widget child;

  @override
  State<LocationTrailLifecycleScope> createState() =>
      _LocationTrailLifecycleScopeState();
}

class _LocationTrailLifecycleScopeState extends State<LocationTrailLifecycleScope>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    LocationTrailService.instance.onAppLifecycleChanged(state);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
