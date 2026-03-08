import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../models/listing.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common_widgets.dart';
import '../detail/listing_detail_screen.dart';

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(userListingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Listings')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showListingForm(context, ref),
        child: const Icon(Icons.add),
      ),
      body: listingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (listings) {
          if (listings.isEmpty) {
            return const Center(
              child: Text('No listings yet. Tap + to add one.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: listings.length,
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () =>
                          _showListingForm(context, ref, listing: listing),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(context, ref, listing),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Listing listing) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Listing'),
        content: Text('Delete "${listing.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(listingRepositoryProvider)
                  .removeListing(listing.listingId!);
              if (context.mounted) {
                SnackbarHelper.showSuccess(context, 'Listing deleted');
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showListingForm(
    BuildContext context,
    WidgetRef ref, {
    Listing? listing,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ListingFormSheet(listing: listing),
    );
  }
}

class ListingFormSheet extends ConsumerStatefulWidget {
  final Listing? listing;

  const ListingFormSheet({super.key, this.listing});

  @override
  ConsumerState<ListingFormSheet> createState() => _ListingFormSheetState();
}

class _ListingFormSheetState extends ConsumerState<ListingFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _websiteCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  late String _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final l = widget.listing;
    _titleCtrl = TextEditingController(text: l?.title);
    _descCtrl = TextEditingController(text: l?.description);
    _addressCtrl = TextEditingController(text: l?.address);
    _phoneCtrl = TextEditingController(text: l?.phone);
    _websiteCtrl = TextEditingController(text: l?.website);
    _latCtrl = TextEditingController(text: l?.latitude?.toString());
    _lngCtrl = TextEditingController(text: l?.longitude?.toString());
    _selectedCategory = l?.category ?? kCategories[1];
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _websiteCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final user = ref.read(currentUserProvider)!;
      final profile = await ref
          .read(firestoreServiceProvider)
          .getUserProfile(user.uid);
      final repo = ref.read(listingRepositoryProvider);

      final phone = _phoneCtrl.text.trim().isEmpty
          ? null
          : _phoneCtrl.text.trim();
      final website = _websiteCtrl.text.trim().isEmpty
          ? null
          : _websiteCtrl.text.trim();
      final lat = double.tryParse(_latCtrl.text);
      final lng = double.tryParse(_lngCtrl.text);

      if (widget.listing == null) {
        final listing = Listing(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          category: _selectedCategory,
          address: _addressCtrl.text.trim(),
          phone: phone,
          website: website,
          latitude: lat,
          longitude: lng,
          ownerId: user.uid,
          ownerName: profile?.displayName ?? user.email ?? '',
        );
        await repo.addListing(listing);
      } else {
        await repo.editListing(widget.listing!.listingId!, {
          FirestoreFields.title: _titleCtrl.text.trim(),
          FirestoreFields.description: _descCtrl.text.trim(),
          FirestoreFields.category: _selectedCategory,
          FirestoreFields.address: _addressCtrl.text.trim(),
          FirestoreFields.phone: phone,
          FirestoreFields.website: website,
          FirestoreFields.latitude: lat,
          FirestoreFields.longitude: lng,
        });
      }

      if (mounted) {
        Navigator.pop(context);
        SnackbarHelper.showSuccess(
          context,
          widget.listing == null ? 'Listing created' : 'Listing updated',
        );
      }
    } catch (e) {
      if (mounted) SnackbarHelper.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.listing == null ? 'Add Listing' : 'Edit Listing',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title *'),
                validator: (v) => Validators.required(v, 'Title'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description *'),
                validator: (v) => Validators.required(v, 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: kCategories
                    .where((c) => c != 'All')
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Address *'),
                validator: (v) => Validators.required(v, 'Address'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: Validators.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _websiteCtrl,
                decoration: const InputDecoration(labelText: 'Website'),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latCtrl,
                      decoration: const InputDecoration(labelText: 'Latitude'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngCtrl,
                      decoration: const InputDecoration(labelText: 'Longitude'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.listing == null ? 'Create' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
