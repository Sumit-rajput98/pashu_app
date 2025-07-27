import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;

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

  // User location coordinates
  final double userLatitude = 23.0263759;
  final double userLongitude = 77.0171924;

  // Category data with icons
  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': 'assets/all.jpg'},
    {'name': 'Buffalo', 'icon': 'assets/buffalo.jpg'},
    {'name': 'Cow', 'icon': 'assets/cow.jpg'},
    {'name': 'Sheep', 'icon': 'assets/sheep.jpg'},
    {'name': 'Goat', 'icon': 'assets/goat.jpg'},
    {'name': 'Camel', 'icon': 'assets/camel.jpg'},
    {'name': 'Bird', 'icon': 'assets/bird.jpg'},
    {'name': 'Cock', 'icon': 'assets/cock.jpg'},
    {'name': 'Dog', 'icon': 'assets/dog.jpg'},
    {'name': 'Horse', 'icon': 'assets/horse.jpg'},
    {'name': 'Pigs', 'icon': 'assets/pig.jpg'},
    {'name': 'Cats', 'icon': 'assets/cat.jpg'},
    {'name': 'Fishes', 'icon': 'assets/fish.png'},
  ];

  @override
  void initState() {
    super.initState();
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

  // Optimized distance calculation using Haversine formula
  double _calculateDistance(double? animalLat, double? animalLng) {
    if (animalLat == null || animalLng == null) {
      return 602.0; // Default distance if coordinates not available
    }

    const double R = 6371; // Earth radius in kilometers
    double phi1 = math.pi * userLatitude / 180;
    double phi2 = math.pi * animalLat / 180;
    double dPhi = math.pi * (animalLat - userLatitude) / 180;
    double dLambda = math.pi * (animalLng - userLongitude) / 180;

    double a =
        math.sin(dPhi / 2) * math.sin(dPhi / 2) +
        math.cos(phi1) *
            math.cos(phi2) *
            math.sin(dLambda / 2) *
            math.sin(dLambda / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return R * c;
  }

  List<AllPashuModel> _getFilteredPashu(List<AllPashuModel> pashuList) {
    List<AllPashuModel> filtered = pashuList;

    if (_selectedCategory != 'All') {
      filtered =
          filtered
              .where(
                (pashu) =>
                    pashu.animatCategory?.toLowerCase() ==
                    _selectedCategory.toLowerCase(),
              )
              .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (pashu) =>
                    pashu.animalname?.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ??
                    false ||
                        pashu.breed!.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ??
                    false,
              )
              .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      //appBar: _buildAppBar(context),
      body: Consumer<AllPashuViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              _buildSearchBar(),
              _buildCategoriesGrid(),
              Expanded(child: _buildAnimalsList(viewModel)),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryDark,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.lightSage.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          const AppLogo(size: 40),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buy Animals',
                style: AppTextStyles.heading.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.lightSage,
                ),
              ),
              Text(
                'Find your perfect livestock',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.lightSage.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.lightSage.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.filter_list_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () {
            // Show filter options
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightSage.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightSage.withOpacity(0.2)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightSage),
        decoration: InputDecoration(
          hintText: 'Search animals, breeds...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.lightSage.withOpacity(0.6),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.lightSage.withOpacity(0.6),
          ),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: AppColors.lightSage.withOpacity(0.6),
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

  // Scrollable Categories Grid
  Widget _buildCategoriesGrid() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        controller: _categoryScrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category['name'];

          return Container(
            width: 70,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category['name'];
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color:
                      isSelected ? Colors.white : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        isSelected
                            ? AppColors.lightSage
                            : AppColors.lightSage.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: AppColors.lightSage.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ]
                          : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Fixed small Category Icon - only white portion visible
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        width: 24, // Smaller icon size
                        height: 24, // Smaller icon size
                        child: Image.asset(
                          category['icon'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.pets_rounded,
                              color:
                                  isSelected
                                      ? AppColors.primaryDark
                                      : AppColors.lightSage,
                              size: 18, // Smaller fallback icon
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 4), // Reduced spacing
                    // Category Name with overflow protection
                    Text(
                      category['name'],
                      style: AppTextStyles.bodyMedium.copyWith(
                        color:
                            isSelected
                                ? AppColors.primaryDark
                                : AppColors.lightSage.withOpacity(0.8),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 9, // Smaller font
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

  // Optimized Animals List with performance improvements
  Widget _buildAnimalsList(AllPashuViewModel viewModel) {
    if (viewModel.isLoading) {
      return _buildShimmerList();
    }

    if (viewModel.error != null) {
      return _buildErrorWidget(viewModel);
    }

    final filteredPashu = _getFilteredPashu(viewModel.pashuList);

    if (filteredPashu.isEmpty) {
      return _buildEmptyWidget();
    }

    return ListView.builder(
      key: const PageStorageKey('animals_list'),
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredPashu.length,
      cacheExtent: 1000, // Increased cache for better performance
      itemBuilder: (context, index) {
        return _buildAnimalListCard(filteredPashu[index], index);
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
          color: AppColors.lightSage.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
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

  // Enhanced Animal Card with overflow prevention and performance optimization
  Widget _buildAnimalListCard(AllPashuModel pashu, int index) {
    double calculatedDistance = 602.0;

    try {
      if (pashu.location != null && pashu.location!.isNotEmpty) {
        Map<String, dynamic> data = jsonDecode(pashu.location ?? '');
        double latitude = data['latitude'] ?? 0.0;
        double longitude = data['longitude'] ?? 0.0;
        calculatedDistance = _calculateDistance(latitude, longitude);
      }
    } catch (e) {
      // Handle JSON parsing errors gracefully
      calculatedDistance = 602.0;
    }

    return Container(
      key: ValueKey(
        'animal_${pashu.id ?? index}',
      ), // Unique key for performance
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.lightSage.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightSage.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Card tap does nothing now
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Optimized Sliding Image Container
                _buildSlidingImageContainer(pashu),

                const SizedBox(width: 16),

                // Animal Details with overflow prevention
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Animal Name & Type with overflow protection
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              pashu.animalname ?? 'Unknown Animal',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.lightSage,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryDark.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                pashu.animatCategory ?? 'Other',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.lightSage,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Breed with overflow protection
                      if (pashu.breed != null && pashu.breed!.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.pets_outlined,
                              color: Colors.white60,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Breed: ${pashu.breed}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.lightSage.withOpacity(0.8),
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

                      // Age & Gender with constraints
                      Row(
                        children: [
                          if (pashu.age != null) ...[
                            const Icon(
                              Icons.cake_outlined,
                              color: Colors.white60,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${pashu.age}y',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.lightSage.withOpacity(0.7),
                                fontSize: 11,
                              ),
                            ),
                          ],
                          if (pashu.age != null && pashu.gender != null)
                            const SizedBox(width: 12),
                          if (pashu.gender != null) ...[
                            Icon(
                              pashu.gender?.toLowerCase() == 'male'
                                  ? Icons.male_rounded
                                  : Icons.female_rounded,
                              color: Colors.white60,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                pashu.gender ?? '',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.lightSage.withOpacity(0.7),
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

                      // Owner Information with overflow protection
                      if (pashu.username != null &&
                          pashu.username!.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline_rounded,
                              color: Colors.white60,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Owner: ${pashu.username}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.lightSage.withOpacity(0.7),
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

                      // Fixed Distance display with proper formatting
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Colors.white60,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            calculatedDistance < 1
                                ? '${(calculatedDistance * 1000).toInt()} m'
                                : '${calculatedDistance.toStringAsFixed(1)} km',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.lightSage.withOpacity(0.7),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Price and Buy Button Row
                      Row(
                        children: [
                          Column(
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
                                  'Call me',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.lightSage.withOpacity(0.6),
                                    fontSize: 9,
                                  ),
                                ),
                            ],
                          ),

                          const Spacer(),

                          // Buy Now Button
                          SizedBox(
                            height: 32,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => AnimalDetailPage(pashu: pashu, distance: calculatedDistance)));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryDark,
                                foregroundColor: AppColors.lightSage,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                              ),
                              child: Text(
                                'Buy Now',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
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

  // Optimized Sliding Image Container with CachedNetworkImage
  Widget _buildSlidingImageContainer(AllPashuModel pashu) {
    final images = <String>[
      if (pashu.pictureOne != null && pashu.pictureOne!.isNotEmpty)
        'https://pashuparivar.com/uploads/${pashu.pictureOne ?? ''}',
      if (pashu.pictureTwo != null && pashu.pictureTwo!.isNotEmpty)
        'https://pashuparivar.com/uploads/${pashu.pictureTwo ?? ''}',
    ];

    return Container(
      width: 110, // Slightly smaller for better layout
      height: 130, // Slightly smaller for better layout
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Optimized Image PageView with CachedNetworkImage
            if (images.isNotEmpty)
              PageView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                    imageUrl: images[index],
                    width: 110,
                    height: 130,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Shimmer.fromColors(
                          baseColor: AppColors.primaryDark.withOpacity(0.1),
                          highlightColor: AppColors.primaryDark.withOpacity(
                            0.2,
                          ),
                          child: Container(
                            color: AppColors.primaryDark.withOpacity(0.1),
                          ),
                        ),
                    errorWidget: (context, url, error) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryDark.withOpacity(0.8),
                              AppColors.primaryDark.withOpacity(0.6),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.pets_rounded,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                      );
                    },
                  );
                },
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryDark.withOpacity(0.8),
                      AppColors.primaryDark.withOpacity(0.6),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.pets_rounded,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ),

            // Favorite Button with wishlist functionality
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () {
                  _addToWishlist(pashu);
                },
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.favorite_border_rounded,
                    color: Colors.red,
                    size: 12,
                  ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Negotiable',
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
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

  // Wishlist functionality with top snackbar
  void _addToWishlist(AllPashuModel pashu) async {
    final wishlistVM = Provider.of<AddToWishlistViewModel>(context, listen: false);

    final body = {
      "id": pashu.id,
      "type": pashu.type,
      "status": pashu.status ?? "Active",
      "lactation": pashu.lactation ?? "",
      "animalname": pashu.animalname,
      "animatCategory": pashu.animatCategory,
      "price": pashu.price,
      "location":pashu.location,
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

    await wishlistVM.addToWishList(body,username!,phoneNumber!);

    if (wishlistVM.errorMessage == null) {
      TopSnackBar.show(
        context,
        message: '${pashu.animalname ?? 'Animal'} added to wishlist',
        backgroundColor: Colors.green,
        textColor: Colors.white,
        icon: Icons.favorite,
      );
    } else {
      TopSnackBar.show(
        context,
        message: 'Failed to add to wishlist: ${wishlistVM.errorMessage}',
        backgroundColor: Colors.red,
        textColor: Colors.white,
        icon: Icons.error,
      );
    }
  }


  // Optimized Detail Modal
  // void _showAnimalDetailModal(AllPashuModel pashu, double distance) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (BuildContext context) {
  //       return Container(
  //         height: MediaQuery.of(context).size.height * 0.85,
  //         decoration: BoxDecoration(
  //           color: AppColors.lightSage,
  //           borderRadius: const BorderRadius.only(
  //             topLeft: Radius.circular(24),
  //             topRight: Radius.circular(24),
  //           ),
  //         ),
  //         child: Column(
  //           children: [
  //             // Handle
  //             Container(
  //               margin: const EdgeInsets.symmetric(vertical: 12),
  //               width: 50,
  //               height: 4,
  //               decoration: BoxDecoration(
  //                 color: AppColors.primaryDark.withOpacity(0.3),
  //                 borderRadius: BorderRadius.circular(2),
  //               ),
  //             ),
  //
  //             // Header
  //             Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 20),
  //               child: Row(
  //                 children: [
  //                   Expanded(
  //                     child: Text(
  //                       pashu.animalname ?? 'Animal Details',
  //                       style: AppTextStyles.heading.copyWith(
  //                         color: AppColors.primaryDark,
  //                         fontSize: 20,
  //                         fontWeight: FontWeight.w700,
  //                       ),
  //                       maxLines: 1,
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                   ),
  //                   IconButton(
  //                     onPressed: () => Navigator.pop(context),
  //                     icon: Icon(
  //                       Icons.close_rounded,
  //                       color: AppColors.primaryDark,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //
  //             // Content with proper overflow handling
  //             Expanded(
  //               child: SingleChildScrollView(
  //                 padding: const EdgeInsets.all(20),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     // Images Section
  //                     _buildDetailImages(pashu),
  //
  //                     const SizedBox(height: 24),
  //
  //                     // Animal Details with overflow protection
  //                     _buildDetailSection('Animal Information', [
  //                       _buildDetailRow(
  //                         'Type',
  //                         pashu.animatCategory ?? 'Unknown',
  //                       ),
  //                       _buildDetailRow('Breed', pashu.breed ?? 'Unknown'),
  //                       _buildDetailRow(
  //                         'Age',
  //                         '${pashu.age ?? 'Unknown'} years',
  //                       ),
  //                       _buildDetailRow('Gender', pashu.gender ?? 'Unknown'),
  //                     ]),
  //
  //                     const SizedBox(height: 20),
  //
  //                     // Price & Negotiation
  //                     _buildDetailSection('Pricing', [
  //                       _buildDetailRow('Price', '₹${pashu.price ?? '0'}'),
  //                       _buildDetailRow(
  //                         'Negotiable',
  //                         (pashu.negotiable?.toLowerCase() == 'yes' ||
  //                                 pashu.negotiable?.toLowerCase() == 'true')
  //                             ? 'Yes'
  //                             : 'No',
  //                       ),
  //                     ]),
  //
  //                     const SizedBox(height: 20),
  //
  //                     // Owner & Location
  //                     _buildDetailSection('Owner & Location', [
  //                       _buildDetailRow('Owner', pashu.username ?? 'Unknown'),
  //                       _buildDetailRow(
  //                         'Distance',
  //                         distance < 1
  //                             ? '${(distance * 1000).toInt()} meters'
  //                             : '${distance.toStringAsFixed(1)} km',
  //                       ),
  //                     ]),
  //
  //                     const SizedBox(height: 30),
  //
  //                     // Buy Button
  //                     SizedBox(
  //                       width: double.infinity,
  //                       height: 50,
  //                       child: ElevatedButton(
  //                         onPressed: () {
  //                           Navigator.pop(context);
  //                           _handlePurchase(pashu);
  //                         },
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: AppColors.primaryDark,
  //                           foregroundColor: AppColors.lightSage,
  //                           elevation: 4,
  //                           shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(16),
  //                           ),
  //                         ),
  //                         child: Text(
  //                           'Contact Seller()',
  //                           style: AppTextStyles.bodyLarge.copyWith(
  //                             fontWeight: FontWeight.w600,
  //                             fontSize: 16,
  //                             color: AppColors.lightSage,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildDetailImages(AllPashuModel pashu) {
    final images = <String>[
      if (pashu.pictureOne != null && pashu.pictureOne!.isNotEmpty)
        'https://pashuparivar.com/uploads/${pashu.pictureOne ?? ''}',
      if (pashu.pictureTwo != null && pashu.pictureTwo!.isNotEmpty)
        'https://pashuparivar.com/uploads/${pashu.pictureTwo ?? ''}',
    ];

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child:
            images.isNotEmpty
                ? PageView.builder(
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return CachedNetworkImage(
                      imageUrl: images[index],
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Shimmer.fromColors(
                            baseColor: AppColors.primaryDark.withOpacity(0.1),
                            highlightColor: AppColors.primaryDark.withOpacity(
                              0.2,
                            ),
                            child: Container(
                              color: AppColors.primaryDark.withOpacity(0.1),
                            ),
                          ),
                      errorWidget: (context, url, error) {
                        return Container(
                          color: AppColors.primaryDark.withOpacity(0.1),
                          child: Center(
                            child: Icon(
                              Icons.pets_rounded,
                              color: AppColors.primaryDark,
                              size: 60,
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
                : Container(
                  color: AppColors.primaryDark.withOpacity(0.1),
                  child: Center(
                    child: Icon(
                      Icons.pets_rounded,
                      color: AppColors.primaryDark,
                      size: 60,
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading.copyWith(
            color: AppColors.primaryDark,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...details,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryDark.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryDark,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(AllPashuViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.lightSage.withOpacity(0.5),
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            viewModel.error ?? 'Something went wrong',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.lightSage.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              viewModel.fetchAllPashu();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightSage,
              foregroundColor: AppColors.primaryDark,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets_outlined,
            color: AppColors.lightSage.withOpacity(0.5),
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            'No animals found',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.lightSage.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedCategory != 'All'
                ? 'Try selecting a different category'
                : 'Check back later for new listings',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.lightSage.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handlePurchase(AllPashuModel pashu) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Purchase request sent for ${pashu.animalname}'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
