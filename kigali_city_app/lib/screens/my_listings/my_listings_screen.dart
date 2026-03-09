// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../models/listing.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common_widgets.dart';
import '../detail/listing_detail_screen.dart';

/// ──────────────────────────────────────────────────────────────
/// My Listings Screen
///
/// Shows listings created by the current user (createdBy == uid).
/// Provides full CRUD operations:
///   ✅ Create: FAB → bottom sheet form
///   ✅ Read: Real-time stream via myListingsStreamProvider
///   ✅ Update: Edit button → pre-filled bottom sheet form
///   ✅ Delete: Delete button with confirmation dialog
///
/// Ownership enforcement:
///   - App level: Only shows listings where createdBy == uid
///   - Firestore rules: Validates request.auth.uid == resource.data.createdBy
/// ──────────────────────────────────────────────────────────────
class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myListingsAsync = ref.watch(myListingsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Listings')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.backgroundDarker,
        onPressed: () => _showListingForm(context, ref),
        child: const Icon(Icons.add),
      ),
      body: myListingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppErrorWidget(
          message: 'Failed to load listings: $error',
          onRetry: () => ref.invalidate(myListingsStreamProvider),
        ),
        data: (listings) {
          if (listings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list_alt, size: 64, color: AppColors.textDim),
                  const SizedBox(height: 16),
                  const Text(
                    'No listings yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap + to create your first listing',
                    style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: listings.length,
            separatorBuilder: (_, __) =>
                Divider(color: AppColors.border.withOpacity(0.3), height: 1),
            itemBuilder: (context, index) {
              final listing = listings[index];
              return ListingCard(
                listing: listing,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ListingDetailScreen(listing: listing),
                  ),
                ),
                onEdit: () => _showListingForm(context, ref, listing: listing),
                onDelete: () => _confirmDelete(context, ref, listing),
              );
            },
          );
        },
      ),
    );
  }

  /// Shows a bottom sheet form for creating or editing a listing.
  void _showListingForm(
    BuildContext context,
    WidgetRef ref, {
    Listing? listing,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ListingFormSheet(listing: listing),
    );
  }

  /// Shows a confirmation dialog before deleting a listing.
  void _confirmDelete(BuildContext context, WidgetRef ref, Listing listing) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'Delete Listing',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${listing.name}"? This action cannot be undone.',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref
                    .read(listingRepositoryProvider)
                    .deleteListing(listing.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Listing deleted'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// ──────────────────────────────────────────────────────────────
/// Listing Form Bottom Sheet (Create / Update)
/// ──────────────────────────────────────────────────────────────
class _ListingFormSheet extends ConsumerStatefulWidget {
  final Listing? listing;

  const _ListingFormSheet({this.listing});

  @override
  ConsumerState<_ListingFormSheet> createState() => _ListingFormSheetState();
}

class _ListingFormSheetState extends ConsumerState<_ListingFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _contactController;
  late TextEditingController _descriptionController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  String _selectedCategory = AppCategories.all.first;
  bool _isLoading = false;

  bool get _isEditing => widget.listing != null;

  @override
  void initState() {
    super.initState();
    final l = widget.listing;
    _nameController = TextEditingController(text: l?.name ?? '');
    _addressController = TextEditingController(text: l?.address ?? '');
    _contactController = TextEditingController(text: l?.contactNumber ?? '');
    _descriptionController = TextEditingController(text: l?.description ?? '');
    _latController = TextEditingController(
      text: l?.latitude.toString() ?? '-1.9403',
    );
    _lngController = TextEditingController(
      text: l?.longitude.toString() ?? '30.0619',
    );
    if (l != null) _selectedCategory = l.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('Not authenticated');

      final repo = ref.read(listingRepositoryProvider);

      if (_isEditing) {
        // UPDATE existing listing
        await repo.updateListing(widget.listing!.id, {
          'name': _nameController.text.trim(),
          'category': _selectedCategory,
          'address': _addressController.text.trim(),
          'contactNumber': _contactController.text.trim(),
          'description': _descriptionController.text.trim(),
          'latitude': double.parse(_latController.text.trim()),
          'longitude': double.parse(_lngController.text.trim()),
        });

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Listing updated!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // CREATE new listing
        final listing = Listing(
          id: '', // Firestore generates the ID
          name: _nameController.text.trim(),
          category: _selectedCategory,
          address: _addressController.text.trim(),
          contactNumber: _contactController.text.trim(),
          description: _descriptionController.text.trim(),
          latitude: double.parse(_latController.text.trim()),
          longitude: double.parse(_lngController.text.trim()),
          createdBy: user.uid,
          timestamp: DateTime.now(),
        );

        await repo.createListing(listing);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Listing created!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
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

              Text(
                _isEditing ? 'Edit Listing' : 'New Listing',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Service Name'),
                style: const TextStyle(color: AppColors.textPrimary),
                validator: (v) => Validators.required(v, 'Name'),
              ),
              const SizedBox(height: 12),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                dropdownColor: AppColors.backgroundCard,
                decoration: const InputDecoration(hintText: 'Category'),
                items: AppCategories.all
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(
                          c,
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
              const SizedBox(height: 12),

              // Address
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(hintText: 'Address'),
                style: const TextStyle(color: AppColors.textPrimary),
                validator: (v) => Validators.required(v, 'Address'),
              ),
              const SizedBox(height: 12),

              // Contact
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(hintText: 'Contact Number'),
                style: const TextStyle(color: AppColors.textPrimary),
                keyboardType: TextInputType.phone,
                validator: (v) => Validators.required(v, 'Contact'),
              ),
              const SizedBox(height: 12),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(hintText: 'Description'),
                style: const TextStyle(color: AppColors.textPrimary),
                maxLines: 3,
                validator: (v) => Validators.required(v, 'Description'),
              ),
              const SizedBox(height: 12),

              // Lat / Lng
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      decoration: const InputDecoration(hintText: 'Latitude'),
                      style: const TextStyle(color: AppColors.textPrimary),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: Validators.latitude,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      decoration: const InputDecoration(hintText: 'Longitude'),
                      style: const TextStyle(color: AppColors.textPrimary),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: Validators.longitude,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.backgroundDarker,
                          ),
                        )
                      : Text(_isEditing ? 'Update Listing' : 'Create Listing'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
