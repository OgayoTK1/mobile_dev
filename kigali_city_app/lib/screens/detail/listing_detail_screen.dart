import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../models/listing.dart';
import '../../widgets/common_widgets.dart'; // add — provides StarRating

/// ──────────────────────────────────────────────────────────────
/// Listing Detail Screen
///
/// Shows full details of a listing including:
///   - Name, category, description
///   - Address and contact info
///   - Google Map with marker at listing coordinates
///   - Navigation button to open Google Maps directions
///
/// How coordinates flow from Firestore → Map:
///   1. Listing model stores latitude/longitude as double
///   2. Listing.fromFirestore() parses them from Firestore doc
///   3. This screen receives the Listing object
///   4. GoogleMap widget uses LatLng(listing.latitude, listing.longitude)
///   5. A Marker is placed at those exact coordinates
///
/// Why coordinates must be stored as double:
///   - LatLng constructor requires double values
///   - Firestore number type maps naturally to Dart double
///   - String coordinates would need parsing (error-prone)
///   - Mathematical operations (distance calc) need doubles
/// ──────────────────────────────────────────────────────────────
class ListingDetailScreen extends StatelessWidget {
  final Listing listing;

  const ListingDetailScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    // Guard nullable lat/lng
    final double lat = listing.latitude ?? 0.0;
    final double lng = listing.longitude ?? 0.0;
    final LatLng position = LatLng(lat, lng);

    return Scaffold(
      appBar: AppBar(title: Text(listing.name)), // name not title
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.backgroundCard, AppColors.categoryBg],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Icon(
                    AppCategories.icons[listing.category] ?? Icons.place,
                    size: 48,
                    color: AppColors.accent,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    listing.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    listing.category,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    listing.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  StarRating(rating: listing.rating ?? 0),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildInfoTile(Icons.location_on, 'Address', listing.address),
                  const SizedBox(height: 10),
                  _buildInfoTile(Icons.phone, 'Contact', listing.contactNumber),
                  const SizedBox(height: 10),
                  _buildInfoTile(
                    Icons.gps_fixed,
                    'Coordinates',
                    // safe null-aware calls
                    '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 200,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: position,
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: MarkerId(listing.id),
                            position: position,
                            infoWindow: InfoWindow(
                              title: listing.name,
                              snippet: listing.address,
                            ),
                          ),
                        },
                        zoomControlsEnabled: false,
                        scrollGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                        myLocationButtonEnabled: false,
                        liteModeEnabled: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => launchGoogleMapsNavigation(
                    latitude: lat,
                    longitude: lng,
                    label: listing.name,
                  ),
                  icon: const Icon(Icons.navigation),
                  label: const Text('Open in Google Maps'),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textDim,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
