import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../models/listing.dart';
import '../../widgets/common_widgets.dart';

class ListingDetailScreen extends StatelessWidget {
  final Listing listing;

  const ListingDetailScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(listing.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (listing.imageUrl != null)
              Image.network(
                listing.imageUrl!,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const SizedBox(height: 220, child: Placeholder()),
              )
            else
              Container(
                height: 160,
                width: double.infinity,
                color: AppColors.surface,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.business,
                  size: 80,
                  color: AppColors.textSecondary,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CategoryBadge(category: listing.category),
                      if (listing.isVerified) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.verified,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    listing.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      StarRating(rating: listing.rating),
                      const SizedBox(width: 6),
                      Text(
                        '${listing.rating.toStringAsFixed(1)} '
                        '(${listing.reviewCount} reviews)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    listing.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Divider(height: 32),
                  _InfoRow(icon: Icons.location_on, text: listing.address),
                  if (listing.phone != null) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => MapLauncher.callPhone(listing.phone!),
                      child: _InfoRow(
                        icon: Icons.phone,
                        text: listing.phone!,
                        isLink: true,
                      ),
                    ),
                  ],
                  if (listing.website != null) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => MapLauncher.openUrl(listing.website!),
                      child: _InfoRow(
                        icon: Icons.language,
                        text: listing.website!,
                        isLink: true,
                      ),
                    ),
                  ],
                  if (listing.hasLocation) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => MapLauncher.openInMaps(
                          latitude: listing.latitude!,
                          longitude: listing.longitude!,
                          label: listing.title,
                        ),
                        icon: const Icon(Icons.directions),
                        label: const Text('Get Directions'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isLink;

  const _InfoRow({required this.icon, required this.text, this.isLink = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isLink ? AppColors.primary : AppColors.textPrimary,
              decoration: isLink ? TextDecoration.underline : null,
            ),
          ),
        ),
      ],
    );
  }
}
