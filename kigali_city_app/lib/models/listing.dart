import 'package:cloud_firestore/cloud_firestore.dart';

/// ──────────────────────────────────────────────────────────────
/// Listing model
///
/// Maps to: Firestore → listings/{listingId}
/// Fields: name, category, address, contactNumber, description,
///         latitude, longitude, createdBy, timestamp
///
/// IMPORTANT: latitude and longitude are stored as double in
/// Firestore (not String). This is critical for flutter_map
/// integration — LatLng requires double values.
/// ──────────────────────────────────────────────────────────────
class Listing {
  final String id;
  final String name;
  final String category;
  final String address;
  final String description;
  final String contactNumber;
  final String? imageUrl;
  final bool isVerified;
  final num? rating;
  final int? reviewCount;
  final String? phone;
  final String? website;
  final double? latitude;
  final double? longitude;
  final String? createdBy;
  final DateTime? timestamp;

  bool get hasLocation => latitude != null && longitude != null;
  String get listingId => id;
  // alias so common_widgets.dart (which uses title) still works
  String get title => name;

  const Listing({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    this.description = '',
    this.contactNumber = '',
    this.imageUrl,
    this.isVerified = false,
    this.rating,
    this.reviewCount,
    this.phone,
    this.website,
    this.latitude,
    this.longitude,
    this.createdBy,
    this.timestamp,
  });

  factory Listing.fromJson(Map<String, dynamic> json, {String id = ''}) {
    return Listing(
      id: id,
      name: json['name'] as String? ?? json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      address: json['address'] as String? ?? '',
      description: json['description'] as String? ?? '',
      contactNumber: json['contactNumber'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      rating: json['rating'] as num?,
      reviewCount: json['reviewCount'] as int?,
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdBy: json['createdBy'] as String?,
      timestamp: (json['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  factory Listing.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Listing.fromJson(data, id: doc.id);
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category,
    'address': address,
    'description': description,
    'contactNumber': contactNumber,
    'imageUrl': imageUrl,
    'isVerified': isVerified,
    'rating': rating,
    'reviewCount': reviewCount,
    'phone': phone,
    'website': website,
    'latitude': latitude,
    'longitude': longitude,
    'createdBy': createdBy,
    'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : null,
  };

  // alias used by firestore_service
  Map<String, dynamic> toFirestore() => toJson();

  Listing copyWith({
    String? id,
    String? name,
    String? category,
    String? address,
    String? description,
    String? contactNumber,
    String? imageUrl,
    bool? isVerified,
    num? rating,
    int? reviewCount,
    String? phone,
    String? website,
    double? latitude,
    double? longitude,
    String? createdBy,
    DateTime? timestamp,
  }) {
    return Listing(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      address: address ?? this.address,
      description: description ?? this.description,
      contactNumber: contactNumber ?? this.contactNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdBy: createdBy ?? this.createdBy,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
