import 'package:amls/cubits/auth/auth_cubit.dart';
import 'package:amls/models/user_location_snapshot.dart';
import 'package:amls/models/user_model.dart';
import 'package:amls/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class _TrailLegendEntry {
  _TrailLegendEntry({
    required this.userId,
    required this.name,
    required this.color,
    required this.points,
    required this.latest,
  });

  final int userId;
  final String name;
  final Color color;
  final List<LatLng> points;
  final UserLocationSnapshot latest;
}

/// Admin map: polylines + latest marker per technician (`GET /api/location-trail?hours=72`).
class TechnicianLocationsPage extends StatefulWidget {
  const TechnicianLocationsPage({super.key});

  @override
  State<TechnicianLocationsPage> createState() => _TechnicianLocationsPageState();
}

class _TechnicianLocationsPageState extends State<TechnicianLocationsPage> {
  final MapController _mapController = MapController();

  static const LatLng _malawiCenter = LatLng(-13.2543, 34.3015);

  List<UserLocationSnapshot>? _items;
  List<_TrailLegendEntry>? _legend;
  String? _error;
  bool _loading = true;
  bool _fitApplied = false;

  static const _palette = <Color>[
    Color(0xFF1565C0),
    Color(0xFFC62828),
    Color(0xFF2E7D32),
    Color(0xFF6A1B9A),
    Color(0xFFEF6C00),
    Color(0xFF00838F),
  ];

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _rebuildLegend() {
    final items = _items;
    if (items == null || items.isEmpty) {
      _legend = [];
      return;
    }
    final groups = <int, List<UserLocationSnapshot>>{};
    for (final s in items) {
      groups.putIfAbsent(s.userId, () => []).add(s);
    }
    final uids = groups.keys.toList()..sort();
    _legend = [];
    for (var i = 0; i < uids.length; i++) {
      final uid = uids[i];
      final list = List<UserLocationSnapshot>.from(groups[uid]!)
        ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
      final pts = list.map((e) => LatLng(e.latitude, e.longitude)).toList();
      _legend!.add(
        _TrailLegendEntry(
          userId: uid,
          name: list.last.displayName,
          color: _palette[i % _palette.length],
          points: pts,
          latest: list.last,
        ),
      );
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _fitApplied = false;
    });
    try {
      final list = await ApiService.fetchLocationTrailForAdmin(withinHours: 72);
      if (!mounted) return;
      setState(() {
        _items = list;
        _rebuildLegend();
        _loading = false;
      });
      _scheduleMapFit();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
          _items = null;
          _legend = null;
        });
      }
    }
  }

  void _scheduleMapFit() {
    final legend = _legend;
    if (legend == null || legend.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _fitApplied) return;
      final all = legend.expand((e) => e.points).toList();
      if (all.isEmpty) return;
      _fitApplied = true;
      try {
        if (all.length == 1) {
          _mapController.move(all.first, 14);
        } else {
          _mapController.fitCamera(
            CameraFit.bounds(
              bounds: LatLngBounds.fromPoints(all),
              padding: const EdgeInsets.only(left: 48, right: 48, top: 32, bottom: 140),
            ),
          );
        }
      } catch (_) {
        // Map may not be laid out yet; ignore.
      }
    });
  }

  Future<void> _openMaps(UserLocationSnapshot s) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${s.latitude},${s.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      // Hide error popup; keep details in logs.
      debugPrint('Could not open maps for ${s.latitude},${s.longitude}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    if (authState is! AuthAuthenticated || authState.user?.role != UserRole.admin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access denied')),
        body: const Center(
          child: Text('Only administrators can view technician locations.'),
        ),
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
          'Technician locations',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _load,
            icon: Icon(Icons.refresh, color: colorScheme.onSurface),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError(colorScheme, textTheme)
              : _legend == null || _legend!.isEmpty
                  ? _buildEmpty(colorScheme, textTheme)
                  : _buildMapBody(colorScheme, textTheme),
    );
  }

  Widget _buildError(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, size: 56, color: colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'Could not load locations',
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(ColorScheme colorScheme, TextTheme textTheme) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: _malawiCenter,
            initialZoom: 6,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.amls',
            ),
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap',
                  onTap: () {
                    launchUrl(
                      Uri.parse('https://openstreetmap.org/copyright'),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: SafeArea(
            top: false,
            child: Material(
              color: colorScheme.surface.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_off_outlined, color: colorScheme.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'No trail data yet',
                            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Technicians enable Location trail in Settings. The API must accept POST /api/location-trail and return points from GET /api/location-trail?hours=72 (JSON in data, locations, or points).',
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapBody(ColorScheme colorScheme, TextTheme textTheme) {
    final legend = _legend!;
    final polylines = <Polyline<Object>>[];
    for (final e in legend) {
      if (e.points.length >= 2) {
        polylines.add(
          Polyline<Object>(
            points: e.points,
            color: e.color,
            strokeWidth: 4,
          ),
        );
      }
    }

    final markers = <Marker>[];
    for (final e in legend) {
      markers.add(
        Marker(
          point: LatLng(e.latest.latitude, e.latest.longitude),
          width: 128,
          height: 40,
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () => _openMaps(e.latest),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: e.color.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  e.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _malawiCenter,
              initialZoom: 6,
              onMapReady: _scheduleMapFit,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.amls',
              ),
              PolylineLayer(polylines: polylines),
              MarkerLayer(markers: markers),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap',
                    onTap: () {
                      launchUrl(
                        Uri.parse('https://openstreetmap.org/copyright'),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        Material(
          elevation: 6,
          color: colorScheme.surface,
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 112,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      'Last 72 hours · tap marker for Google Maps',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      itemCount: legend.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final e = legend[i];
                        final n = e.points.length;
                        return ActionChip(
                          avatar: CircleAvatar(
                            backgroundColor: e.color,
                            radius: 6,
                            child: const SizedBox.shrink(),
                          ),
                          label: Text('${e.name} ($n)'),
                          onPressed: () => _openMaps(e.latest),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
