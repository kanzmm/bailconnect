import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/listing_provider.dart';
import '../../../core/utils/format_helper.dart';

class ListingDetailScreen extends ConsumerWidget {
  final String listingId;

  const ListingDetailScreen({super.key, required this.listingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingAsync = ref.watch(listingDetailProvider(listingId));

    return Scaffold(
      body: listingAsync.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, st) => Scaffold(
          appBar: AppBar(),
          body: Center(child: Text('Erreur: $error')),
        ),
        data: (listing) {
          if (listing == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('Annonce non trouvée')),
            );
          }

          return CustomScrollView(
            slivers: [
              // App Bar avec image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: listing.imageUrl.isNotEmpty
                      ? Image.network(listing.imageUrl, fit: BoxFit.cover)
                      : Container(
                          color: Colors.grey.shade300,
                          child: Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Colors.grey.shade600,
                          ),
                        ),
                ),
              ),
              // Contenu
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // En-tête
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  listing.title,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${listing.city}, ${listing.district}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.favorite_border),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Prix
                      Text(
                        FormatHelper.formatPrice(listing.price),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Caractéristiques
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildFeature(
                            icon: Icons.bed,
                            label: 'Chambres',
                            value: '${listing.bedrooms}',
                          ),
                          _buildFeature(
                            icon: Icons.bathtub,
                            label: 'Salles de bain',
                            value: '${listing.bathrooms}',
                          ),
                          _buildFeature(
                            icon: Icons.square_foot,
                            label: 'Surface',
                            value: '${listing.surfaceArea}m²',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        listing.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Équipements
                      if (listing.amenities.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Équipements',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: listing.amenities
                                  .map((amenity) => Chip(label: Text(amenity)))
                                  .toList(),
                            ),
                          ],
                        ),
                      const SizedBox(height: 24),
                      // Propriétaire
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: listing.ownerImage != null
                                  ? NetworkImage(listing.ownerImage!)
                                  : null,
                              child: listing.ownerImage == null
                                  ? Icon(
                                      Icons.person,
                                      color: Colors.grey.shade600,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    listing.ownerName ?? 'Propriétaire',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (listing.ownerRating != null)
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          size: 16,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${listing.ownerRating}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => context.push(
                                '/messages?listing=${listing.id}',
                              ),
                              icon: const Icon(Icons.message, size: 16),
                              label: const Text('Message'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFeature({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
