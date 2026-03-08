import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

class Listing {
  final String? listingId;
  final String title;
  final String description;
  final String category;
  final String address;
  final String? phone;
  final String? website;
  final double? latitude;
  final double? longitude;
  final String ownerId;
  final String ownerName;
  final double rating;
  final int reviewCount;
  final String? imageUrl;
  final DateTime? updatedAt;
  final bool isVerified;

  const Listing({
    this.listingId,
    required this.title,
    required this.description,
    required this.category,
    required this.address,
    this.phone,
    this.website,
    this.latitude,
    this.longitude,
    required this.ownerId,
    required this.ownerName,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.imageUrl,
    this.updatedAt,
    this.isVerified = false,
  });

  bool get hasLocation => latitude != null && longitude != null;

  factory Listing.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Listing(
      listingId: doc.id,
      title: data[FirestoreFields.title] as String? ?? '',
      description: data[FirestoreFields.description] as String? ?? '',
      category: data[FirestoreFields.category] as String? ?? '',
      address: data[FirestoreFields.address] as String? ?? '',
      phone: data[FirestoreFields.phone] as String?,
      website: data[FirestoreFields.website] as String?,
      latitude: (data[FirestoreFields.latitude] as num?)?.toDouble(),
      longitude: (data[FirestoreFields.longitude] as num?)?.toDouble(),
      ownerId: data[FirestoreFields.ownerId] as String? ?? '',
      ownerName: data[FirestoreFields.ownerName] as String? ?? '',
      rating: (data[FirestoreFields.rating] as num?)?.toDouble() ?? 0.0,
      reviewCount: data[FirestoreFields.reviewCount] as int? ?? 0,
      imageUrl: data[FirestoreFields.imageUrl] as String?,
      updatedAt: data[FirestoreFields.updatedAt] != null
          ? (data[FirestoreFields.updatedAt] as Timestamp).toDate()
          : null,
      isVerified: data[FirestoreFields.isVerified] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      FirestoreFields.title: title,
      FirestoreFields.description: description,
      FirestoreFields.category: category,
      FirestoreFields.address: address,
      FirestoreFields.phone: phone,
      FirestoreFields.website: website,
      FirestoreFields.latitude: latitude,
      FirestoreFields.longitude: longitude,
      FirestoreFields.ownerId: ownerId,
      FirestoreFields.ownerName: ownerName,
      FirestoreFields.rating: rating,
      FirestoreFields.reviewCount: reviewCount,
      FirestoreFields.imageUrl: imageUrl,
      FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      FirestoreFields.isVerified: isVerified,
    };
  }

  Listing copyWith({
    String? listingId,
    String? title,
    String? description,
    String? category,
    String? address,
    String? phone,
    String? website,
    double? latitude,
    double? longitude,
    double? rating,
    int? reviewCount,
    String? imageUrl,
    bool? isVerified,
  }) {
    return Listing(
      listingId: listingId ?? this.listingId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      ownerId: ownerId,
      ownerName: ownerName,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrl: imageUrl ?? this.imageUrl,
      updatedAt: updatedAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
