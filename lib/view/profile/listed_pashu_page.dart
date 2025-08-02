import 'package:flutter/material.dart';
import 'package:pashu_app/core/shared_pref_helper.dart';
import 'package:pashu_app/view/custom_app_bar.dart';

import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/app_colors.dart';
import '../../core/app_logo.dart';
import '../../core/navigation_controller.dart';
import '../../model/pashu/all_pashu.dart';
import '../../view_model/pashuVM/all_pashu_view_model.dart';
import '../auth/profile_page.dart';

class ListedPashuPage extends StatefulWidget {
  final VoidCallback? onBack;
  const ListedPashuPage({super.key, this.onBack});

  @override
  State<ListedPashuPage> createState() => _ListedPashuPageState();
}

class _ListedPashuPageState extends State<ListedPashuPage> {
  String? userPhoneNumber;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadUserPhoneAndFetchData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserPhoneAndFetchData() async {
    // Get phone number from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    userPhoneNumber = prefs.getString('phone_number'); // Adjust key as per your implementation

    // Fetch all pashu data
    if (mounted) {
      Provider.of<AllPashuViewModel>(context, listen: false).fetchAllPashu();
    }
  }

  List<AllPashuModel> _getFilteredPashu(List<AllPashuModel> pashuList) {
    if (userPhoneNumber == null) return [];

    return pashuList.where((pashu) =>
    pashu.usernumber == userPhoneNumber ||
        pashu.userphone == userPhoneNumber
    ).toList();
  }

  Future<bool> _handleBackPress() async {
    String? phoneNumber = await SharedPrefHelper.getPhoneNumber();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ProfilePage(phoneNumber: phoneNumber ?? '')),
      );
    }
    return false; // prevent default pop behavior
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light grayish-white background

      body: Consumer<AllPashuViewModel>(
        builder: (context, viewModel, child) {
          return RefreshIndicator(
            onRefresh: () => viewModel.fetchAllPashu(),
            color: AppColors.primaryDark,
            backgroundColor: Colors.white,
            child: _buildContent(viewModel),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryDark.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryDark.withOpacity(0.2)),
          ),
          child: Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.primaryDark,
            size: 20,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          const AppLogo(size: 40),
          const SizedBox(width: 12),
          Text(
            l10n.yourListedPashu,
            style: AppTextStyles.heading.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryDark.withOpacity(0.2)),
            ),
            child: Icon(
              Icons.refresh_rounded,
              color: AppColors.primaryDark,
              size: 20,
            ),
          ),
          onPressed: () {
            Provider.of<AllPashuViewModel>(context, listen: false).fetchAllPashu();
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildContent(AllPashuViewModel viewModel) {
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

    return Column(
      children: [
        // Stats Header
        _buildStatsHeader(filteredPashu),

        // Pashu List
        Expanded(
          child: ListView.builder(
            key: const PageStorageKey('listed_pashu_list'),
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: filteredPashu.length,
            cacheExtent: 1000,
            itemBuilder: (context, index) {
              return _buildPashuCard(filteredPashu[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsHeader(List<AllPashuModel> filteredPashu) {
    final l10n = AppLocalizations.of(context)!;
    print(filteredPashu.map((e) => e.status).toList());

    final totalListings = filteredPashu.length;
    final activeListings = filteredPashu.where((p) => p.status?.toLowerCase() == 'active').length;
    final pendingListings = filteredPashu.where((p) => p.status?.toLowerCase() == 'pending').length;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
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
        border: Border.all(
          color: AppColors.primaryDark,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(l10n.total, totalListings.toString(), Colors.blue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatItem(l10n.active, activeListings.toString(), Colors.green),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatItem(l10n.pending, pendingListings.toString(), Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.heading.copyWith(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primaryDark.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
              color: Colors.white,
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
                    children: List.generate(5, (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        width: double.infinity,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    )),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPashuCard(AllPashuModel pashu, int index) {
    final l10n = AppLocalizations.of(context)!;
    final images = <String>[
      if (pashu.pictureOne != null && pashu.pictureOne!.isNotEmpty)
        'https://pashuparivar.com/uploads/${pashu.pictureOne}',
      if (pashu.pictureTwo != null && pashu.pictureTwo!.isNotEmpty)
        'https://pashuparivar.com/uploads/${pashu.pictureTwo}',
    ];

    final bool isPending = pashu.status?.toLowerCase() == 'pending';

    return Container(
      key: ValueKey('listed_pashu_${pashu.id ?? index}'),
      margin: const EdgeInsets.only(bottom: 16),
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
        border: Border.all(
          color: isPending ? Colors.red : AppColors.primaryDark,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
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
                      color: AppColors.primaryDark.withOpacity(0.2),
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
                          PageView.builder(
                            itemCount: images.length,
                            itemBuilder: (context, imgIndex) {
                              return CachedNetworkImage(
                                imageUrl: images[imgIndex],
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
                              );
                            },
                          )
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
                ),

                const SizedBox(width: 16),

                // Details Section
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
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            constraints: const BoxConstraints(maxWidth: 60),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: AppColors.primaryDark.withOpacity(0.3),
                              ),
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
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Breed
                      if (pashu.breed != null && pashu.breed!.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.pets_outlined,
                              color: AppColors.primaryDark.withOpacity(0.6),
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

                      // Age and Gender
                      Row(
                        children: [
                          if (pashu.age != null) ...[
                            Icon(
                              Icons.cake_outlined,
                              color: AppColors.primaryDark.withOpacity(0.6),
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
                              color: AppColors.primaryDark.withOpacity(0.6),
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

                      // Address
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: AppColors.primaryDark.withOpacity(0.6),
                            size: 11,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              pashu.address ?? l10n.locationNotAvailable,
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

                      const SizedBox(height: 8),

                      // Price and Status
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '₹${pashu.price ?? '0'}',
                                style: AppTextStyles.heading.copyWith(
                                  color: isPending ? Colors.grey : Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (pashu.negotiable?.toLowerCase() == 'yes')
                                Text(
                                  l10n.negotiable,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.primaryDark.withOpacity(0.6),
                                    fontSize: 8,
                                  ),
                                ),
                            ],
                          ),

                          const Spacer(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Status Badge
          if (isPending)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  l10n.pendingStatus,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(AllPashuViewModel viewModel) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.primaryDark.withOpacity(0.5),
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              l10n.failedToLoadListings,
              style: AppTextStyles.heading.copyWith(
                color: AppColors.primaryDark,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              viewModel.error ?? l10n.somethingWentWrong,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryDark.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                viewModel.fetchAllPashu();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets_outlined,
              color: AppColors.primaryDark.withOpacity(0.5),
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              l10n.noListedAnimals,
              style: AppTextStyles.heading.copyWith(
                color: AppColors.primaryDark,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noListedAnimalsDescription,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryDark.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

          ],
        ),
      ),
    );
  }

  void _editPashu(AllPashuModel pashu) {
    // Navigate to edit page with pashu data
    Navigator.pushNamed(
      context,
      '/edit-pashu',
      arguments: pashu,
    );
  }

  void _deletePashu(AllPashuModel pashu) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.primaryDark, width: 2),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.deleteListing,
                style: AppTextStyles.heading.copyWith(
                  color: AppColors.primaryDark,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            l10n.deleteConfirmation( pashu.animalname ?? l10n.animal),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryDark.withOpacity(0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryDark.withOpacity(0.6),
              ),
              child: Text(
                l10n.cancel,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryDark.withOpacity(0.6),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement delete API call
                _showDeleteSuccessSnackBar(pashu.animalname ?? l10n.animal);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteSuccessSnackBar(String animalName) {
    final l10n = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.deleteSuccessMessage(animalName)),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
