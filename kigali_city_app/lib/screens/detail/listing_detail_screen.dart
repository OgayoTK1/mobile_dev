import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../models/listing.dart';
import '../../widgets/common_widgets.dart';

class ListingDetailScreen extends StatelessWidget {
  final Listing listing;

  const ListingDetailScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final double lat = listing.latitude ?? 0.0;
    final double lng = listing.longitude ?? 0.0;
    final LatLng position = LatLng(lat, lng);
    final bool hasValidCoords = listing.hasLocation;

    return Scaffold(
      appBar: AppBar(title: Text(listing.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header card ───────────────────────────────────
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

            // ─── Info tiles ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildInfoTile(
                    Icons.location_on,
                    'Address',
                    listing.address,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoTile(
                    Icons.phone,
                    'Contact',
                    listing.contactNumber,
                  ),
                  if (hasValidCoords) ...[
                    const SizedBox(height: 10),
                    _buildInfoTile(
                      Icons.gps_fixed,
                      'Coordinates',
                      '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ─── Map ───────────────────────────────────────────
            if (hasValidCoords) ...[
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
                        height: 220,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: position,
                            initialZoom: 15,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.none,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.kigali.city_app',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: position,
                                  width: 48,
                                  height: 48,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.accent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2.5,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 6,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.place,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SimpleAttributionWidget(
                              source: Text('OpenStreetMap contributors'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ─── Open in Maps button ────────────────────────
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
            ],

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
