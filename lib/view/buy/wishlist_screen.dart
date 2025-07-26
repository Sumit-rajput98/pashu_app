import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/app_colors.dart';
import '../../core/top_snacbar.dart';
import '../../model/pashu/all_pashu.dart';
import '../../view_model/pashuVM/wishlist_view_model.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  String _selectedCategory = 'All';
  final ScrollController _categoryScrollController = ScrollController();
  final ScrollController _scrollController = ScrollController();

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
      Provider.of<WishlistViewModel>(context, listen: false).fetchWishlist();
    });
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<AllPashuModel> _getFilteredWishlist(List<AllPashuModel> list) {
    if (_selectedCategory == 'All') return list;
    return list
        .where(
          (pashu) =>
      pashu.animatCategory?.toLowerCase() ==
          _selectedCategory.toLowerCase(),
    )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.red, size: 28),
            const SizedBox(width: 10),
            Text(
              'Wishlist',
              style: AppTextStyles.heading.copyWith(
                color: AppColors.lightSage,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: Consumer<WishlistViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              _buildCategoriesGrid(),
              Expanded(child: _buildAnimalsList(viewModel)),
            ],
          );
        },
      ),
    );
  }

  // Fixed Categories Grid with proper constraints
  Widget _buildCategoriesGrid() {
    return Container(
      height: 70, // Reduced height to prevent overflow
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
            width: 60, // Reduced width to prevent overflow
            margin: const EdgeInsets.symmetric(horizontal: 3), // Reduced margin
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
                  borderRadius: BorderRadius.circular(8), // Smaller radius
                  border: Border.all(
                    color:
                    isSelected
                        ? AppColors.lightSage
                        : AppColors.lightSage.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow:
                  isSelected
                      ? [
                    BoxShadow(
                      color: AppColors.lightSage.withOpacity(0.3),
                      blurRadius: 4, // Reduced blur
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: SizedBox(
                        width: 20, // Smaller icon
                        height: 20, // Smaller icon
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
                              size: 14, // Smaller fallback icon
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 3), // Reduced spacing
                    Flexible( // Added Flexible to prevent overflow
                      child: Text(
                        category['name'],
                        style: AppTextStyles.bodyMedium.copyWith(
                          color:
                          isSelected
                              ? AppColors.primaryDark
                              : AppColors.lightSage.withOpacity(0.8),
                          fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 8, // Smaller font
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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

  Widget _buildAnimalsList(WishlistViewModel viewModel) {
    if (viewModel.isLoading) {
      return _buildShimmerList();
    }
    if (viewModel.error != null) {
      return _buildErrorWidget(viewModel);
    }
    final filtered = _getFilteredWishlist(viewModel.wishlist);
    if (filtered.isEmpty) {
      return _buildEmptyWidget();
    }
    return ListView.builder(
      key: const PageStorageKey('wishlist_animals_list'),
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filtered.length,
      cacheExtent: 1000, // Added for better performance
      itemBuilder: (context, index) {
        return _buildAnimalListCard(filtered[index], viewModel);
      },
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 6,
      itemBuilder: (context, index) {
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
                  width: 110, // Consistent with main card
                  height: 130, // Consistent with main card
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
      },
    );
  }

  // Fixed Animal List Card with proper overflow prevention
  Widget _buildAnimalListCard(
      AllPashuModel pashu,
      WishlistViewModel viewModel,
      ) {
    final images = <String>[
      if (pashu.pictureOne != null && pashu.pictureOne!.isNotEmpty)
        'https://pashuparivar.com/uploads/${pashu.pictureOne ?? ''}',
      if (pashu.pictureTwo != null && pashu.pictureTwo!.isNotEmpty)
        'https://pashuparivar.com/uploads/${pashu.pictureTwo ?? ''}',
    ];

    return Container(
      key: ValueKey('wishlist_animal_${pashu.id}'),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.lightSage.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightSage.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fixed Image Container
              Container(
                width: 110,
                height: 130,
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
                      // Image or Fallback
                      if (images.isNotEmpty)
                        PageView.builder(
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            return CachedNetworkImage(
                              imageUrl: images[index],
                              width: 110,
                              height: 130,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: AppColors.primaryDark.withOpacity(0.1),
                                highlightColor: AppColors.primaryDark.withOpacity(0.2),
                                child: Container(
                                  color: AppColors.primaryDark.withOpacity(0.1),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
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

                      // Favorite Icon (always visible in wishlist)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 12,
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
              ),

              const SizedBox(width: 16),

              // Animal Details with proper overflow handling
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Category Row
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            pashu.animalname ?? 'Unknown Animal',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.lightSage,
                              fontWeight: FontWeight.w600,
                              fontSize: 15, // Slightly smaller
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          flex: 1,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 60), // Max width constraint
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              pashu.animatCategory ?? 'Other',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.lightSage,
                                fontSize: 8,
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

                    const SizedBox(height: 5),

                    // Breed Row
                    if (pashu.breed != null && pashu.breed!.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.pets_outlined,
                            color: Colors.white60,
                            size: 11,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              'Breed: ${pashu.breed}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.lightSage.withOpacity(0.8),
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                    ],

                    // Age and Gender Row
                    Row(
                      children: [
                        if (pashu.age != null) ...[
                          const Icon(
                            Icons.cake_outlined,
                            color: Colors.white60,
                            size: 11,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${pashu.age}y',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.lightSage.withOpacity(0.7),
                              fontSize: 10,
                            ),
                          ),
                        ],
                        if (pashu.age != null && pashu.gender != null)
                          const SizedBox(width: 10),
                        if (pashu.gender != null) ...[
                          Icon(
                            pashu.gender?.toLowerCase() == 'male'
                                ? Icons.male_rounded
                                : Icons.female_rounded,
                            color: Colors.white60,
                            size: 11,
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              pashu.gender ?? '',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.lightSage.withOpacity(0.7),
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 3),

                    // Owner Row
                    if (pashu.username != null && pashu.username!.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline_rounded,
                            color: Colors.white60,
                            size: 11,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              'Owner: ${pashu.username}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.lightSage.withOpacity(0.7),
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                    ],

                    // Address Row with proper overflow handling
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.white60,
                          size: 11,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            pashu.address ?? 'Location not available',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.lightSage.withOpacity(0.7),
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Price and Buttons Row
                    Row(
                      children: [
                        // Price Column
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${pashu.price ?? '0'}',
                              style: AppTextStyles.heading.copyWith(
                                color: Colors.red,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (pashu.negotiable?.toLowerCase() == 'yes' ||
                                pashu.negotiable?.toLowerCase() == 'true')
                              Text(
                                'Call me',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.lightSage.withOpacity(0.6),
                                  fontSize: 8,
                                ),
                              ),
                          ],
                        ),

                        const Spacer(),

                        // Buttons Column (stacked vertically to prevent overflow)
                        Column(
                          children: [
                            // Buy Now Button
                            SizedBox(
                              width: 70, // Fixed width to prevent overflow
                              height: 28,
                              child: ElevatedButton(
                                onPressed: () {
                                  _showAnimalDetailModal(pashu);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryDark,
                                  foregroundColor: AppColors.lightSage,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                child: Text(
                                  'Buy Now',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 4),

                            // Remove Button
                            SizedBox(
                              width: 70, // Fixed width to prevent overflow
                              height: 28,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final success = await viewModel.removeFromWishlist(
                                    name: pashu.username ?? '',
                                    phoneNumber: pashu.userphone ?? '',
                                    id: pashu.id ?? 0,
                                  );
                                  if (success) {
                                    TopSnackBar.show(
                                      context,
                                      message: 'Removed from wishlist',
                                      backgroundColor: Colors.red,
                                      icon: Icons.delete,
                                    );
                                  } else {
                                    TopSnackBar.show(
                                      context,
                                      message: 'Failed to remove',
                                      backgroundColor: Colors.red,
                                      icon: Icons.error,
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                child: Text(
                                  'Remove',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  void _showAnimalDetailModal(AllPashuModel pashu) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: AppColors.lightSage,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        pashu.animalname ?? 'Animal Details',
                        style: AppTextStyles.heading.copyWith(
                          color: AppColors.primaryDark,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),

              // Content placeholder - you can expand this with full details
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Animal Details Coming Soon',
                        style: AppTextStyles.heading.copyWith(
                          color: AppColors.primaryDark,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Full animal details modal will be implemented here',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryDark.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(WishlistViewModel viewModel) {
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
              viewModel.fetchWishlist();
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
            Icons.favorite_border_rounded,
            color: AppColors.lightSage.withOpacity(0.5),
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            'No wishlist animals found',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.lightSage.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adding some animals to your wishlist!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.lightSage.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
