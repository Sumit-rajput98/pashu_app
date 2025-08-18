import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/app_logo.dart';
import '../../model/pashu/all_pashu.dart';
import '../../view_model/pashuVM/all_pashu_view_model.dart';

class SoldOutHistoryPage extends StatefulWidget {
  final VoidCallback? onBack;
  const SoldOutHistoryPage({super.key, this.onBack});

  @override
  State<SoldOutHistoryPage> createState() => _SoldOutHistoryPageState();
}

class _SoldOutHistoryPageState extends State<SoldOutHistoryPage> {
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
    final prefs = await SharedPreferences.getInstance();
    userPhoneNumber = prefs.getString('phone_number');

    if (mounted) {
      Provider.of<AllPashuViewModel>(context, listen: false).fetchAllPashu();
    }
  }

  List<AllPashuModel> _getSoldPashu(List<AllPashuModel> pashuList) {
    if (userPhoneNumber == null) return [];

    return pashuList.where((pashu) =>
    (pashu.usernumber == userPhoneNumber || pashu.userphone == userPhoneNumber) &&
        pashu.status?.toLowerCase() == 'sold' // Only sold items
    ).toList();
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

  PreferredSizeWidget _buildAppBar() {
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
            'Sold Out History',
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

    final soldPashu = _getSoldPashu(viewModel.pashuList);

    if (soldPashu.isEmpty) {
      return _buildEmptyWidget();
    }

    return Column(
      children: [
        // Stats Header
        _buildStatsHeader(soldPashu),

        // Sold Pashu List
        Expanded(
          child: ListView.builder(
            key: const PageStorageKey('sold_pashu_list'),
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: soldPashu.length,
            cacheExtent: 1000,
            itemBuilder: (context, index) {
              return _buildSoldPashuCard(soldPashu[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsHeader(List<AllPashuModel> soldPashu) {
    final totalSold = soldPashu.length;
    final totalRevenue = soldPashu.fold<double>(0, (sum, pashu) {
      final price = double.tryParse(pashu.price ?? '0') ?? 0;
      return sum + price;
    });
    final avgPrice = totalSold > 0 ? (totalRevenue / totalSold) : 0;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.withOpacity(0.1),
            Colors.green.withOpacity(0.05),
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
            child: _buildStatItem('Total Sold', totalSold.toString(), Colors.green),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatItem('Revenue', '₹${totalRevenue.toInt()}', Colors.orange),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatItem('Avg Price', '₹${avgPrice.toInt()}', Colors.blue),
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
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primaryDark.withOpacity(0.7),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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

  Widget _buildSoldPashuCard(AllPashuModel pashu, int index) {
    final images = <String>[
      if (pashu.pictureOne != null && pashu.pictureOne!.isNotEmpty)
        'https://pashuparivar.com/uploads/${pashu.pictureOne}',
      if (pashu.pictureTwo != null && pashu.pictureTwo!.isNotEmpty)
        'https://pashuparivar.com/uploads/${pashu.pictureTwo}',
    ];

    return Container(
      key: ValueKey('sold_pashu_${pashu.id ?? index}'),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.withOpacity(0.1),
            Colors.red.withOpacity(0.05),
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
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Container with Sold Overlay
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
                              return Stack(
                                children: [
                                  CachedNetworkImage(
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
                                  ),
                                  // Sold Overlay
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                    ),
                                    child: const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.check_circle_rounded,
                                            color: Colors.green,
                                            size: 32,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'SOLD',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          )
                        else
                          Stack(
                            children: [
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
                              // Sold Overlay
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                ),
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.green,
                                        size: 32,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'SOLD',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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

                // Details Section with improved text visibility
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Category with Sold Badge
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              pashu.animalname ?? 'Unknown Animal',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.primaryDark.withOpacity(0.7), // Better visibility
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                decoration: TextDecoration.lineThrough, // Strike through
                                decorationColor: AppColors.primaryDark.withOpacity(0.5),
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
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Text(
                              'SOLD',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.red,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
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
                              color: AppColors.primaryDark.withOpacity(0.5),
                              size: 11,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                'Breed: ${pashu.breed}',
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

                      // Age and Gender
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
                                color: AppColors.primaryDark.withOpacity(0.6),
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
                                  color: AppColors.primaryDark.withOpacity(0.6),
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
                            color: AppColors.primaryDark.withOpacity(0.5),
                            size: 11,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              pashu.address ?? 'Location not available',
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

                      const SizedBox(height: 8),

                      // Sale Date (if available) and Price
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sold for ₹${pashu.price ?? '0'}',
                                style: AppTextStyles.heading.copyWith(
                                  color: Colors.green,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Transaction completed',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primaryDark.withOpacity(0.6),
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          // View Receipt Button
                          SizedBox(
                            width: 80,
                            height: 32,
                            child: ElevatedButton(
                              onPressed: () {
                                _viewSaleDetails(pashu);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                              ),
                              child: Text(
                                'View Receipt',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 8,
                                  color: Colors.white, // Explicit white for visibility
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

          // Large SOLD Badge
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green, Colors.green.shade700],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'SOLD OUT',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
// Add this import at the top of your file


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
              l10n.failedToLoadHistory,
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
              Icons.history_rounded,
              color: AppColors.primaryDark.withOpacity(0.5),
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              l10n.noSoldAnimals,
              style: AppTextStyles.heading.copyWith(
                color: AppColors.primaryDark,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noSoldAnimalsDescription,
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

  void _viewSaleDetails(AllPashuModel pashu) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.white, // Changed to white for light theme
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border.all(color: AppColors.primaryDark, width: 2),
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: Colors.green,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Sale Receipt',
                        style: AppTextStyles.heading.copyWith(
                          color: AppColors.primaryDark,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
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

              // Receipt Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Success Message
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Animal Sold Successfully!',
                              style: AppTextStyles.heading.copyWith(
                                color: Colors.green,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Sale Details
                      _buildReceiptSection('Animal Details', [
                        _buildReceiptRow('Name', pashu.animalname ?? 'N/A'),
                        _buildReceiptRow('Category', pashu.animatCategory ?? 'N/A'),
                        _buildReceiptRow('Breed', pashu.breed ?? 'N/A'),
                        _buildReceiptRow('Age', '${pashu.age ?? 'N/A'} years'),
                        _buildReceiptRow('Gender', pashu.gender ?? 'N/A'),
                      ]),

                      const SizedBox(height: 20),

                      _buildReceiptSection('Sale Information', [
                        _buildReceiptRow('Sale Price', '₹${pashu.price ?? '0'}'),
                        _buildReceiptRow('Negotiable', pashu.negotiable ?? 'No'),
                        _buildReceiptRow('Sale Date', 'Recently'), // You can add actual date if available
                        _buildReceiptRow('Transaction Status', 'Completed'),
                      ]),

                      const SizedBox(height: 30),

                      // Footer Note
                      Container(
                        width: double.infinity,
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
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primaryDark.withOpacity(0.2)),
                        ),
                        child: Text(
                          'Thank you for using Pashu Parivar! This receipt serves as confirmation of your successful animal sale.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primaryDark.withOpacity(0.7),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
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

  Widget _buildReceiptSection(String title, List<Widget> items) {
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
        ...items,
      ],
    );
  }

  Widget _buildReceiptRow(String label, String value) {
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
}
