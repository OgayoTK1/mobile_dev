import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/listing.dart';
import '../../providers/app_providers.dart';
import '../detail/listing_detail_screen.dart';

class MapViewScreen extends ConsumerStatefulWidget {
  const MapViewScreen({super.key});

  @override
  ConsumerState<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends ConsumerState<MapViewScreen> {
  // ignore: unused_field
  GoogleMapController? _mapController;
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

  Set<Marker> _buildMarkers(List<Listing> listings) {
    return listings
        .where((l) => l.hasLocation)
        .map(
          (l) => Marker(
            markerId: MarkerId(l.listingId ?? l.title),
            position: LatLng(l.latitude!, l.longitude!),
            infoWindow: InfoWindow(
              title: l.title,
              snippet: l.category,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ListingDetailScreen(listing: l),
                ),
              ),
            ),
          ),
        )
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(allListingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Map View')),
      body: listingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (listings) => GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: _kigaliCenter,
            zoom: 13,
          ),
          markers: _buildMarkers(listings),
          onMapCreated: (controller) => _mapController = controller,
          myLocationButtonEnabled: _locationPermissionGranted,
          myLocationEnabled: _locationPermissionGranted,
        ),
      ),
    );
  }
}
