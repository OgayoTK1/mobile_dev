import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../models/listing.dart';
import '../../providers/app_providers.dart';
import '../detail/listing_detail_screen.dart';

class MapViewScreen extends ConsumerStatefulWidget {
  const MapViewScreen({super.key});

  @override
  ConsumerState<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends ConsumerState<MapViewScreen> {
  final MapController _mapController = MapController();
  static const _kigaliCenter = LatLng(-1.9441, 30.0619);
  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    if (mounted) {
      setState(() => _locationPermissionGranted = status.isGranted);
    }
  }

  void _onMarkerTap(Listing listing) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _MarkerBottomSheet(listing: listing),
    );
  }

  List<Marker> _buildMarkers(List<Listing> listings) {
    return listings
        .where((l) => l.hasLocation)
        .map(
          (l) => Marker(
            point: LatLng(l.latitude!, l.longitude!),
            width: 44,
            height: 44,
            child: GestureDetector(
              onTap: () => _onMarkerTap(l),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.place, color: Colors.white, size: 22),
              ),
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(allListingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Map View')),
      body: listingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                'Failed to load listings: $e',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(allListingsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (listings) => FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: _kigaliCenter,
            initialZoom: 13,
            minZoom: 5,
            maxZoom: 19,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.kigali.city_app',
              maxZoom: 19,
            ),
            MarkerLayer(markers: _buildMarkers(listings)),
            const RichAttributionWidget(
              attributions: [
                TextSourceAttribution('OpenStreetMap contributors'),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'zoom_in',
            onPressed: () => _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom + 1,
            ),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'zoom_out',
            onPressed: () => _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom - 1,
            ),
            child: const Icon(Icons.remove),
          ),
          if (_locationPermissionGranted) ...[
            const SizedBox(height: 8),
            FloatingActionButton.small(
              heroTag: 'center',
              onPressed: () => _mapController.move(_kigaliCenter, 13),
              child: const Icon(Icons.my_location),
            ),
          ],
        ],
      ),
    );
  }
}

class _MarkerBottomSheet extends StatelessWidget {
  final Listing listing;
  const _MarkerBottomSheet({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textDim,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.categoryBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  AppCategories.icons[listing.category] ?? Icons.place,
                  color: AppColors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      listing.category,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 16,
                color: AppColors.textDim,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  listing.address,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => launchGoogleMapsNavigation(
                    latitude: listing.latitude!,
                    longitude: listing.longitude!,
                    label: listing.name,
                  ),
                  icon: const Icon(Icons.navigation, size: 18),
                  label: const Text('Directions'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ListingDetailScreen(listing: listing),
                      ),
                    );
                  },
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('Details'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
