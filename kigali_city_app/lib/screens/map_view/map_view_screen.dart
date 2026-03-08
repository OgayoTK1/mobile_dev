import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  bool _mapError = false;

  @override
  void initState() {
    super.initState();
    // Catch unhandled platform exceptions from Google Maps (e.g. missing API key)
    final previousHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exception is PlatformException ||
          details.exceptionAsString().contains('API key')) {
        if (mounted) setState(() => _mapError = true);
      } else {
        previousHandler?.call(details);
      }
    };
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
        data: (listings) {
          if (_mapError) {
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Enable Maps SDK for Android in Google Cloud Console to use this feature.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _kigaliCenter,
              zoom: 13,
            ),
            markers: _buildMarkers(listings),
            onMapCreated: (controller) => _mapController = controller,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
          );
        },
      ),
    );
  }
}
