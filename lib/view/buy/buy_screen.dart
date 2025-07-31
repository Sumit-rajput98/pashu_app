import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_colors.dart';
import '../../core/app_logo.dart';
import '../../core/shared_pref_helper.dart';
import '../../core/top_snacbar.dart';
import '../../model/pashu/all_pashu.dart';
import '../../view_model/pashuVM/add_to_wishlist_view_model.dart';
import '../../view_model/pashuVM/all_pashu_view_model.dart';
import 'animal_detail_page.dart';

class BuyPage extends StatefulWidget {
  const BuyPage({super.key});

  @override
  State<BuyPage> createState() => _BuyPageState();
}

class _BuyPageState extends State<BuyPage> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _categoryScrollController = ScrollController();

  // User location coordinates - will be loaded from SharedPreferences
  double? userLatitude;
  double? userLongitude;

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AllPashuViewModel>(context, listen: false).fetchAllPashu();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  // Load user location from SharedPreferences
  Future<void> _loadUserLocation() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userLatitude = prefs.getDouble('latitude');
      userLongitude = prefs.getDouble('longitude');
    });
    print('User location loaded: $userLatitude, $userLongitude');
  }

  // Helper function to convert degrees to radians
  double _toRad(double degree) {
    return (degree * math.pi) / 180;
  }

  // Updated distance calculation function based on your React Native function
  double _calculateDistance(double? animalLat, double? animalLng) {
    if (animalLat == null || animalLng == null || userLatitude == null || userLongitude == null) {
      return 999.0;
    }

    const double R = 6371;
    final double dLat = _toRad(animalLat - userLatitude!);
    final double dLon = _toRad(animalLng - userLongitude!);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(userLatitude!)) *
            math.cos(_toRad(animalLat)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final double distance = R * c;

    return distance.ceilToDouble();
  }

  // Get localized categories
  List<Map<String, dynamic>> getLocalizedCategories(AppLocalizations l10n) {
    return [
      {'name': l10n.all, 'key': 'All', 'icon': 'assets/all.jpg'},
      {'name': l10n.buffalo, 'key': 'Buffalo', 'icon': 'assets/buffalo.jpg'},
      {'name': l10n.cow, 'key': 'Cow', 'icon': 'assets/cow.jpg'},
      {'name': l10n.sheep, 'key': 'Sheep', 'icon': 'assets/sheep.jpg'},
      {'name': l10n.goat, 'key': 'Goat', 'icon': 'assets/goat.jpg'},
      {'name': l10n.camel, 'key': 'Camel', 'icon': 'assets/camel.jpg'},
      {'name': l10n.bird, 'key': 'Bird', 'icon': 'assets/bird.jpg'},
      {'name': l10n.cock, 'key': 'Cock', 'icon': 'assets/cock.jpg'},
      {'name': l10n.dog, 'key': 'Dog', 'icon': 'assets/dog.jpg'},
      {'name': l10n.horse, 'key': 'Horse', 'icon': 'assets/horse.jpg'},
      {'name': l10n.pigs, 'key': 'Pigs', 'icon': 'assets/pig.jpg'},
      {'name': l10n.cats, 'key': 'Cats', 'icon': 'assets/cat.jpg'},
      {'name': l10n.fishes, 'key': 'Fishes', 'icon': 'assets/fish.png'},
    ];
  }

  // Updated filter and sort function
  List<AllPashuModel> _getFilteredAndSortedPashu(List<AllPashuModel> pashuList) {
    List<AllPashuModel> filtered = pashuList;

    // Filter by status - only show ACTIVE animals
    filtered = filtered.where((pashu) =>
    pashu.status?.toLowerCase() == 'active'
    ).toList();

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((pashu) =>
      pashu.animatCategory?.toLowerCase() == _selectedCategory.toLowerCase()
      ).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((pashu) =>
      (pashu.animalname?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (pashu.breed?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }

    // Create a list with distance calculations for sorting
    List<Map<String, dynamic>> animalsWithDistance = filtered.map((pashu) {
      double distance = 999.0;

      try {
        if (pashu.location != null && pashu.location!.isNotEmpty) {
          Map<String, dynamic> locationData = jsonDecode(pashu.location!);
          double? animalLat = locationData['latitude']?.toDouble();
          double? animalLng = locationData['longitude']?.toDouble();
          distance = _calculateDistance(animalLat, animalLng);
        }
      } catch (e) {
        print('Error parsing location for animal ${pashu.id}: $e');
      }

      return {
        'pashu': pashu,
        'distance': distance,
      };
    }).toList();

    // Sort by distance (nearest first)
    animalsWithDistance.sort((a, b) =>
        (a['distance'] as double).compareTo(b['distance'] as double)
    );

    // Extract sorted pashu list
    return animalsWithDistance.map((item) => item['pashu'] as AllPashuModel).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<AllPashuViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              _buildSearchBar(l10n),
              _buildCategoriesGrid(l10n),
              Expanded(child: _buildAnimalsList(viewModel, l10n)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryDark, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryDark),
        decoration: InputDecoration(
          hintText: l10n.searchAnimalsBreeds,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primaryDark.withOpacity(0.6),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.primaryDark.withOpacity(0.6),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: Icon(
              Icons.clear_rounded,
              color: AppColors.primaryDark.withOpacity(0.6),
            ),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
              });
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(AppLocalizations l10n) {
    final localizedCategories = getLocalizedCategories(l10n);

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        controller: _categoryScrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: localizedCategories.length,
        itemBuilder: (context, index) {
          final category = localizedCategories[index];
          final isSelected = _selectedCategory == category['key'];

          return Container(
            width: 70,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category['key'];
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isSelected
                        ? [
                      AppColors.primaryDark.withOpacity(0.15),
                      AppColors.primaryDark.withOpacity(0.08),
                    ]
                        : [
                      AppColors.lightSage.withOpacity(0.1),
                      AppColors.lightSage.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryDark
                        : AppColors.primaryDark.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: AppColors.primaryDark.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: Image.asset(
                          category['icon'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.pets_rounded,
                              color: isSelected
                                  ? AppColors.primaryDark
                                  : AppColors.primaryDark.withOpacity(0.6),
                              size: 18,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category['name'],
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isSelected
                            ? AppColors.primaryDark
                            : AppColors.primaryDark.withOpacity(0.7),
                        fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 9,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimalsList(AllPashuViewModel viewModel, AppLocalizations l10n) {
    if (viewModel.isLoading) {
      return _buildShimmerList();
    }

    if (viewModel.error != null) {
      return _buildErrorWidget(viewModel, l10n);
    }

    // Use the updated filter and sort function
    final filteredAndSortedPashu = _getFilteredAndSortedPashu(viewModel.pashuList);

    if (filteredAndSortedPashu.isEmpty) {
      return _buildEmptyWidget(l10n);
    }

    return ListView.builder(
      key: const PageStorageKey('animals_list'),
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredAndSortedPashu.length,
      cacheExtent: 1000,
      itemBuilder: (context, index) {
        return _buildAnimalListCard(filteredAndSortedPashu[index], index, l10n);
      },
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 6,
      itemBuilder: (context, index) {
        return _buildShimmerListCard();
      },
    );
  }

  Widget _buildShimmerListCard() {
    return Shimmer.fromColors(
      baseColor: AppColors.lightSage.withOpacity(0.1),
      highlightColor: AppColors.lightSage.withOpacity(0.2),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.lightSage.withOpacity(0.1),
              AppColors.lightSage.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryDark, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 120,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  5,
                      (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      width: double.infinity,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimalListCard(AllPashuModel pashu, int index, AppLocalizations l10n) {
    double calculatedDistance = 999.0;

    try {
      if (pashu.location != null && pashu.location!.isNotEmpty) {
        Map<String, dynamic> data = jsonDecode(pashu.location ?? '');
        double? latitude = data['latitude']?.toDouble();
        double? longitude = data['longitude']?.toDouble();
        calculatedDistance = _calculateDistance(latitude, longitude);
      }
    } catch (e) {
      calculatedDistance = 999.0;
    }

    return Container(
      key: ValueKey('animal_${pashu.id ?? index}'),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryDark, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AnimalDetailPage(
                  pashu: pashu,
                  distance: calculatedDistance,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAutoScrollingImageContainer(pashu, l10n),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Animal Name & Status
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              pashu.animalname ?? l10n.unknownAnimal,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.green.withOpacity(0.3)),
                            ),
                            child: Text(
                              'ACTIVE',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.green,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Category
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.primaryDark.withOpacity(0.3)),
                        ),
                        child: Text(
                          pashu.animatCategory ?? l10n.other,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primaryDark,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Breed
                      if (pashu.breed != null && pashu.breed!.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(Icons.pets_outlined, color: AppColors.primaryDark.withOpacity(0.6), size: 12),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${l10n.breed}: ${pashu.breed}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primaryDark.withOpacity(0.7),
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],

                      // Age & Gender
                      Row(
                        children: [
                          if (pashu.age != null) ...[
                            Icon(Icons.cake_outlined, color: AppColors.primaryDark.withOpacity(0.6), size: 12),
                            const SizedBox(width: 4),
                            Text(
                              '${pashu.age}y',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primaryDark.withOpacity(0.7),
                                fontSize: 11,
                              ),
                            ),
                          ],
                          if (pashu.age != null && pashu.gender != null) const SizedBox(width: 12),
                          if (pashu.gender != null) ...[
                            Icon(
                              pashu.gender?.toLowerCase() == 'male' ? Icons.male_rounded : Icons.female_rounded,
                              color: AppColors.primaryDark.withOpacity(0.6),
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                pashu.gender ?? '',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primaryDark.withOpacity(0.7),
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Owner
                      if (pashu.username != null && pashu.username!.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(Icons.person_outline_rounded, color: AppColors.primaryDark.withOpacity(0.6), size: 12),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${l10n.owner}: ${pashu.username}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primaryDark.withOpacity(0.7),
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],

                      // Distance
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, color: calculatedDistance < 999 ? Colors.blue : Colors.grey, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '${calculatedDistance.toInt()} Km',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: calculatedDistance < 999 ? Colors.blue : AppColors.primaryDark.withOpacity(0.5),
                              fontSize: 11,
                              fontWeight: calculatedDistance < 999 ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Price & Buttons (Responsive)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '₹${pashu.price ?? '0'}',
                                style: AppTextStyles.heading.copyWith(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (pashu.negotiable?.toLowerCase() == 'yes' ||
                                  pashu.negotiable?.toLowerCase() == 'true')
                                Text(
                                  l10n.callMe,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.primaryDark.withOpacity(0.6),
                                    fontSize: 9,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _addToWishlist(pashu, l10n),
                                      icon: const Icon(Icons.favorite_border_rounded, size: 14),
                                      label: FittedBox(
                                        child: Text(
                                          'Wishlist',
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        elevation: 2,
                                        shadowColor: Colors.red.withOpacity(0.3),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AnimalDetailPage(
                                              pashu: pashu,
                                              distance: calculatedDistance,
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryDark,
                                        foregroundColor: Colors.white,
                                        elevation: 4,
                                        shadowColor: AppColors.primaryDark.withOpacity(0.3),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      ),
                                      child: FittedBox(
                                        child: Text(
                                          l10n.buyNow,
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAutoScrollingImageContainer(AllPashuModel pashu, AppLocalizations l10n) {
    final images = <String>[
      if (pashu.pictureOne != null && pashu.pictureOne!.isNotEmpty)
        'https://pashuparivar.com/uploads/${pashu.pictureOne ?? ''}',
      if (pashu.pictureTwo != null && pashu.pictureTwo!.isNotEmpty)
        'https://pashuparivar.com/uploads/${pashu.pictureTwo ?? ''}',
    ];

    return Container(
      width: 110,
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryDark.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            if (images.isNotEmpty)
              _AutoScrollingPageView(images: images)
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.lightSage.withOpacity(0.2),
                      AppColors.lightSage.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.pets_rounded,
                    color: AppColors.primaryDark,
                    size: 35,
                  ),
                ),
              ),

            // Negotiable Badge
            if (pashu.negotiable?.toLowerCase() == 'yes' ||
                pashu.negotiable?.toLowerCase() == 'true')
              Positioned(
                bottom: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.green.shade700),
                  ),
                  child: Text(
                    l10n.negotiable,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            // Image count indicator
            if (images.length > 1)
              Positioned(
                bottom: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${images.length}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontSize: 8,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _addToWishlist(AllPashuModel pashu, AppLocalizations l10n) async {
    final wishlistVM = Provider.of<AddToWishlistViewModel>(context, listen: false);

    final body = {
      "id": pashu.id,
      "type": pashu.type,
      "status": pashu.status ?? "Active",
      "lactation": pashu.lactation ?? "",
      "animalname": pashu.animalname,
      "animatCategory": pashu.animatCategory,
      "price": pashu.price,
      "location": pashu.location,
      "address": pashu.address,
      "negotiable": pashu.negotiable,
      "pictureOne": pashu.pictureOne,
      "pictureTwo": pashu.pictureTwo,
      "username": pashu.username,
      "usernumber": pashu.usernumber,
      "userphone": pashu.userphone,
      "age": pashu.age,
      "gender": pashu.gender,
      "discription": pashu.discription,
      "referralcode": pashu.referralcode,
      "breed": pashu.breed,
    };

    final username = await SharedPrefHelper.getUsername();
    final phoneNumber = await SharedPrefHelper.getPhoneNumber();

    await wishlistVM.addToWishList(body, username!, phoneNumber!);

    if (wishlistVM.errorMessage == null) {
      TopSnackBar.show(
        context,
        message: '${pashu.animalname ?? l10n.animal} ${l10n.addedToWishlist}',
        backgroundColor: Colors.green,
        textColor: Colors.white,
        icon: Icons.favorite,
      );
    } else {
      TopSnackBar.show(
        context,
        message: '${l10n.failedToAddToWishlist}: ${wishlistVM.errorMessage}',
        backgroundColor: Colors.red,
        textColor: Colors.white,
        icon: Icons.error,
      );
    }
  }

  Widget _buildErrorWidget(AllPashuViewModel viewModel, AppLocalizations l10n) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.primaryDark.withOpacity(0.5),
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              viewModel.error ?? l10n.somethingWentWrong,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.primaryDark.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                viewModel.fetchAllPashu();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(AppLocalizations l10n) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets_outlined,
              color: AppColors.primaryDark.withOpacity(0.5),
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'No Active Animals Found',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.primaryDark.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedCategory != 'All'
                  ? l10n.trySelectingDifferentCategory
                  : 'Check back later for new active listings',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryDark.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handlePurchase(AllPashuModel pashu, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n.purchaseRequestSent} ${pashu.animalname}'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// Auto-scrolling PageView Widget
class _AutoScrollingPageView extends StatefulWidget {
  final List<String> images;

  const _AutoScrollingPageView({required this.images});

  @override
  State<_AutoScrollingPageView> createState() => _AutoScrollingPageViewState();
}

class _AutoScrollingPageViewState extends State<_AutoScrollingPageView> {
  late PageController _pageController;
  late Timer _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Only start auto-scroll if there are multiple images
    if (widget.images.length > 1) {
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && widget.images.length > 1) {
        _currentPage = (_currentPage + 1) % widget.images.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.images.length,
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      itemBuilder: (context, index) {
        return CachedNetworkImage(
          imageUrl: widget.images[index],
          width: 110,
          height: 130,
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: AppColors.lightSage.withOpacity(0.1),
            highlightColor: AppColors.lightSage.withOpacity(0.2),
            child: Container(
              color: AppColors.lightSage.withOpacity(0.1),
            ),
          ),
          errorWidget: (context, url, error) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.lightSage.withOpacity(0.2),
                    AppColors.lightSage.withOpacity(0.1),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.pets_rounded,
                  color: AppColors.primaryDark,
                  size: 35,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
// Add this wrapper class at the end of your file or in a separate file
class AnimalDetailPageWrapper extends StatelessWidget {
  final AllPashuModel pashu;
  final double distance;
  final VoidCallback onBack;

  const AnimalDetailPageWrapper({
    super.key,
    required this.pashu,
    required this.distance,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom back header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      pashu.animalname ?? 'Animal Details',
                      style: AppTextStyles.heading.copyWith(
                        color: AppColors.primaryDark,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // The actual animal detail page content
            Expanded(
              child: AnimalDetailPage(
                pashu: pashu,
                distance: distance,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
