import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/listing.dart';
import '../../providers/app_providers.dart';
import '../detail/listing_detail_screen.dart';

// Set to true once Maps SDK for Android is enabled in Google Cloud Console
// for project: kigali-city-directory-39aad
const bool kMapsEnabled = false;

class MapViewScreen extends ConsumerStatefulWidget {
  const MapViewScreen({super.key});

  @override
  ConsumerState<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends ConsumerState<MapViewScreen> {
  // ignore: unused_field
  GoogleMapController? _mapController;
  static const _kigaliCenter = LatLng(-1.9441, 30.0619);

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

  Widget _buildMapUnavailable() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Map unavailable',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Maps SDK for Android needs to be enabled in Google Cloud Console.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!kMapsEnabled) {
      return Scaffold(
        appBar: AppBar(title: const Text('Map View')),
        body: _buildMapUnavailable(),
      );
    }

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
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
        ),
      ),
    );
  }
}
