import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common_widgets.dart';
import '../detail/listing_detail_screen.dart';

class DirectoryScreen extends ConsumerWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(searchedListingsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kigali Directory'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(112),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search listings...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (v) =>
                      ref.read(searchQueryProvider.notifier).state = v,
                ),
              ),
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: kCategories.length,
                  itemBuilder: (context, index) {
                    final cat = kCategories[index];
                    final isSelected = cat == selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (_) => ref
                            .read(selectedCategoryProvider.notifier)
                            .state = cat,
                        selectedColor: AppColors.primary,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: listingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (listings) {
          if (listings.isEmpty) {
            return const Center(child: Text('No listings found'));
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
              );
            },
          );
        },
      ),
    );
  }
}
