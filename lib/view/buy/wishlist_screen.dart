import 'package:flutter/material.dart';
import 'package:pashu_app/view/buy/animal_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/app_colors.dart';
import '../../core/shared_pref_helper.dart';
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

  List<AllPashuModel> _getFilteredWishlist(List<AllPashuModel> list) {
    if (_selectedCategory == 'All') return list;
    return list.where((pashu) =>
    pashu.animatCategory?.toLowerCase() == _selectedCategory.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Consumer<WishlistViewModel>(
        builder: (context, viewModel, child) {
          return Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              children: [
                _buildCategoriesGrid(l10n),
                Expanded(child: _buildAnimalsList(viewModel, l10n)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesGrid(AppLocalizations l10n) {
    final localizedCategories = getLocalizedCategories(l10n);

    return Container(
      height: 70,
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
            width: 60,
            margin: const EdgeInsets.symmetric(horizontal: 3),
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
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryDark
                        : AppColors.primaryDark.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: AppColors.primaryDark.withOpacity(0.15),
                      blurRadius: 5,
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
                        width: 20,
                        height: 20,
                        child: Image.asset(
                          category['icon'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.pets_rounded,
                              color: isSelected
                                  ? AppColors.primaryDark
                                  : AppColors.primaryDark.withOpacity(0.5),
                              size: 14,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Flexible(
                      child: Text(
                        category['name'],
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isSelected
                              ? AppColors.primaryDark
                              : AppColors.primaryDark.withOpacity(0.7),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 8,
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
                  width: 110,
                  height: 130,
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
                            ))),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimalsList(WishlistViewModel viewModel, AppLocalizations l10n) {
    if (viewModel.isLoading) {
      return _buildShimmerList();
    }
    if (viewModel.error != null) {
      return _buildErrorWidget(viewModel, l10n);
    }
    final filtered = _getFilteredWishlist(viewModel.wishlist);
    if (filtered.isEmpty) {
      return _buildEmptyWidget(l10n);
    }
    return ListView.builder(
      key: const PageStorageKey('wishlist_animals_list'),
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filtered.length,
      cacheExtent: 1000,
      itemBuilder: (context, index) {
        return _buildAnimalListCard(filtered[index], viewModel, l10n);
      },
    );
  }

  Widget _buildAnimalListCard(
      AllPashuModel pashu,
      WishlistViewModel viewModel,
      AppLocalizations l10n,
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Container
              Container(
                width: 110,
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primaryDark.withOpacity(0.2)),
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
                        PageView.builder(
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            return CachedNetworkImage(
                              imageUrl: images[index],
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
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.primaryDark.withOpacity(0.15),
                            ),
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 12,
                          ),
                        ),
                      ),
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
              ),

              const SizedBox(width: 16),

              // Animal Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Category
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            pashu.animalname ?? l10n.unknownAnimal,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          flex: 1,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 60),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              pashu.animatCategory ?? l10n.other,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primaryDark,
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
                    if (pashu.breed != null && pashu.breed!.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.pets_outlined,
                            color: AppColors.primaryDark.withOpacity(0.5),
                            size: 11,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              '${l10n.breed}: ${pashu.breed}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primaryDark.withOpacity(0.7),
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
                    Row(
                      children: [
                        if (pashu.age != null) ...[
                          Icon(
                            Icons.cake_outlined,
                            color: AppColors.primaryDark.withOpacity(0.5),
                            size: 11,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${pashu.age}y',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primaryDark.withOpacity(0.7),
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
                            color: AppColors.primaryDark.withOpacity(0.5),
                            size: 11,
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              pashu.gender ?? '',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primaryDark.withOpacity(0.7),
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
                    if (pashu.username != null && pashu.username!.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.primaryDark.withOpacity(0.5),
                            size: 11,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              '${l10n.owner}: ${pashu.username}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primaryDark.withOpacity(0.6),
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
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: AppColors.primaryDark.withOpacity(0.5),
                          size: 11,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            pashu.address ?? l10n.locationNotAvailable,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primaryDark.withOpacity(0.6),
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
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
                                l10n.callMe,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primaryDark.withOpacity(0.6),
                                  fontSize: 8,
                                ),
                              ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          children: [
                            // VIEW/BUY Button
                            SizedBox(
                              width: 70,
                              height: 28,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AnimalDetailPage(
                                              pashu: pashu, distance: 0)));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryDark,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                child: Text(
                                  l10n.buyNow,
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
                              width: 70,
                              height: 28,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final username = await SharedPrefHelper.getUsername();
                                  final phoneNumber = await SharedPrefHelper.getPhoneNumber();
                                  final success = await viewModel.removeFromWishlist(
                                    name: username!,
                                    phoneNumber: phoneNumber!,
                                    id: pashu.id ?? 0,
                                  );
                                  if (success) {
                                    TopSnackBar.show(
                                      context,
                                      message: l10n.removedFromWishlist,
                                      backgroundColor: Colors.red,
                                      icon: Icons.delete,
                                    );
                                  } else {
                                    TopSnackBar.show(
                                      context,
                                      message: l10n.failedToRemove,
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
                                  l10n.remove,
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

  Widget _buildErrorWidget(WishlistViewModel viewModel, AppLocalizations l10n) {
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
              onPressed: () => viewModel.fetchWishlist(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
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
              Icons.favorite_border_rounded,
              color: AppColors.primaryDark.withOpacity(0.5),
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noWishlistAnimalsFound,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.primaryDark.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tryAddingAnimalsToWishlist,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryDark.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
