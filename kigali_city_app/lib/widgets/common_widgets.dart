import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/listing.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;

  const StarRating({super.key, required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return Icon(Icons.star, size: size, color: AppColors.starColor);
        } else if (i < rating) {
          return Icon(Icons.star_half, size: size, color: AppColors.starColor);
        } else {
          return Icon(
            Icons.star_border,
            size: size,
            color: AppColors.starColor,
          );
        }
      }),
    );
  }
}

class CategoryBadge extends StatelessWidget {
  final String category;

  const CategoryBadge({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        category,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ListingCard({
    super.key,
    required this.listing,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: listing.imageUrl != null
                    ? Image.network(
                        listing.imageUrl!,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            listing.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (listing.isVerified)
                          const Icon(
                            Icons.verified,
                            size: 16,
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    CategoryBadge(category: listing.category),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        StarRating(rating: listing.rating),
                        const SizedBox(width: 4),
                        Text(
                          listing.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            listing.address,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              trailing != null? trailing! : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 72,
      height: 72,
      color: AppColors.surface,
      child: const Icon(
        Icons.business,
        color: AppColors.textSecondary,
        size: 32,
      ),
    );
  }
}
