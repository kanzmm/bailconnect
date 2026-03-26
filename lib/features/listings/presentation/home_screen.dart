import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/listing_provider.dart';
import '../../../core/constants/enums.dart';
import '../../../core/utils/format_helper.dart';
import '../../../shared/models/listing_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedCity;
  ListingType? _selectedType;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(listingProvider);

    // Afficher la bonne page selon l'index
    if (_selectedIndex == 1) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('BailConnect'),
          backgroundColor: Colors.blue.shade600,
          elevation: 0,
        ),
        body: const Center(
          child: Text('Messages - Rechargement de la page...'),
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      );
    } else if (_selectedIndex == 2) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('BailConnect'),
          backgroundColor: Colors.blue.shade600,
          elevation: 0,
        ),
        body: const Center(child: Text('Profile - Rechargement de la page...')),
        bottomNavigationBar: _buildBottomNavBar(),
      );
    }

    // Page par défaut: Home
    return Scaffold(
      appBar: AppBar(
        title: const Text('BailConnect'),
        backgroundColor: Colors.blue.shade600,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade600,
            child: Column(
              children: [
                // Recherche rapide
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Filtres rapides
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'Location',
                        selected: _selectedType == ListingType.rent,
                        onSelected: () =>
                            setState(() => _selectedType = ListingType.rent),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Vente',
                        selected: _selectedType == ListingType.sale,
                        onSelected: () =>
                            setState(() => _selectedType = ListingType.sale),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Lubumbashi',
                        selected: _selectedCity == 'Lubumbashi',
                        onSelected: () =>
                            setState(() => _selectedCity = 'Lubumbashi'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Liste des annonces
          Expanded(
            child: listingsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, st) => Center(child: Text('Erreur: $error')),
              data: (listings) => listings.isEmpty
                  ? const Center(child: Text('Aucune annonce trouvée'))
                  : ListView.builder(
                      itemCount: listings.length,
                      padding: const EdgeInsets.all(8),
                      itemBuilder: (context, index) {
                        return _buildListingCard(context, listings[index]);
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade600,
        onPressed: () => context.push('/create-listing'),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.blue.shade600,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == 1) {
          context.push('/messages');
        } else if (index == 2) {
          context.push('/profile');
        } else {
          setState(() => _selectedIndex = index);
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
        BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Messages'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      backgroundColor: Colors.white.withValues(alpha: 0.3),
      selectedColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.blue.shade600 : Colors.white,
      ),
    );
  }

  Widget _buildListingCard(BuildContext context, Listing listing) {
    return GestureDetector(
      onTap: () => context.push('/listing/${listing.id}'),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: SizedBox(
          height: 220,
          child: Column(
            children: [
              // Image
              Container(
                height: 130,
                color: Colors.grey.shade300,
                child: listing.imageUrl.isNotEmpty
                    ? Image.network(listing.imageUrl, fit: BoxFit.cover)
                    : Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey.shade600,
                        ),
                      ),
              ),
              // Contenu
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${listing.city}, ${listing.district}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            FormatHelper.formatPrice(listing.price),
                            style: TextStyle(
                              color: Colors.blue.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.bed_outlined,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${listing.bedrooms}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
