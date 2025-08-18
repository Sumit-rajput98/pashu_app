import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/app_colors.dart';
import '../../core/app_logo.dart';
import '../../core/navigation_controller.dart';
import '../../model/pashu/category_model.dart';
import '../../view_model/pashuVM/get_category_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LiveRacePage extends StatefulWidget {
  const LiveRacePage({super.key});

  @override
  State<LiveRacePage> createState() => _LiveRacePageState();
}

class _LiveRacePageState extends State<LiveRacePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GetCategoryViewModel>(
        context,
        listen: false,
      ).fetchAllCategories();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light grayish-white background
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Consumer<GetCategoryViewModel>(
          builder: (context, viewModel, child) {
            return RefreshIndicator(
              onRefresh: () => viewModel.fetchAllCategories(),
              color: AppColors.primaryDark,
              backgroundColor: Colors.white,
              child: _buildContent(viewModel, l10n),
            );
          },
        ),
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
          Expanded(
            child: Text(
              l10n.liveRaceTitle,
              style: AppTextStyles.heading.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
            Provider.of<GetCategoryViewModel>(
              context,
              listen: false,
            ).fetchAllCategories();
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildContent(GetCategoryViewModel viewModel, AppLocalizations l10n) {
    if (viewModel.isLoading) {
      return _buildShimmerContent(l10n);
    }

    if (viewModel.error != null) {
      return _buildErrorWidget(viewModel, l10n);
    }

    if (viewModel.categoryList.isEmpty) {
      return _buildEmptyWidget(l10n);
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildHeader(l10n),
          _buildCategoriesList(viewModel.categoryList, l10n),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.withOpacity(0.15),
              Colors.red.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryDark, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.liveRaceHeader,
                    style: AppTextStyles.heading.copyWith(
                      color: AppColors.primaryDark,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              l10n.chooseRaceCategory,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryDark.withOpacity(0.8),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            Text(
              l10n.raceExperienceSubheader,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryDark.withOpacity(0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesList(List<CategoryModel> categories, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return _buildCategoryCard(categories[index], index, l10n);
        },
      ),
    );
  }

  Widget _buildCategoryCard(CategoryModel category, int index, AppLocalizations l10n) {
    final List<List<Color>> gradientColors = [
      [Colors.blue.withOpacity(0.15), Colors.blue.withOpacity(0.08)],
      [Colors.green.withOpacity(0.15), Colors.green.withOpacity(0.08)],
      [Colors.purple.withOpacity(0.15), Colors.purple.withOpacity(0.08)],
      [Colors.orange.withOpacity(0.15), Colors.orange.withOpacity(0.08)],
      [Colors.teal.withOpacity(0.15), Colors.teal.withOpacity(0.08)],
      [Colors.indigo.withOpacity(0.15), Colors.indigo.withOpacity(0.08)],
    ];

    final List<Color> accentColors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
    ];

    final gradients = gradientColors[index % gradientColors.length];
    final accentColor = accentColors[index % accentColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToRaceDetail(category),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              minHeight: 180,
              maxHeight: 200,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradients,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryDark, width: 2),
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
                // Background pattern
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Category Image
                      Container(
                        width: 100,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: accentColor.withOpacity(0.3),
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
                          child: category.categoryImage != null && category.categoryImage!.isNotEmpty
                              ? CachedNetworkImage(
                            imageUrl: 'https://pashuparivar.com/uploads/${category.categoryImage}',
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
                                    accentColor.withOpacity(0.2),
                                    accentColor.withOpacity(0.1),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.sports_rounded,
                                  color: accentColor,
                                  size: 30,
                                ),
                              ),
                            ),
                          )
                              : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  accentColor.withOpacity(0.2),
                                  accentColor.withOpacity(0.1),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.sports_rounded,
                                color: accentColor,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Category Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Category Name
                            Text(
                              category.categoryName ?? l10n.raceCategoryFallback,
                              style: AppTextStyles.heading.copyWith(
                                color: AppColors.primaryDark,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 8),

                            // Category Detail
                            Text(
                              category.categoryDetail ?? l10n.raceCategoryDetailFallback,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primaryDark.withOpacity(0.7),
                                fontSize: 13,
                                height: 1.3,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 12),

                            // Race Status
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        l10n.liveNow,
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    l10n.tapToJoin,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.primaryDark.withOpacity(0.6),
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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

                // Live Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          l10n.liveBadge,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerContent(AppLocalizations l10n) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header Shimmer
            Shimmer.fromColors(
              baseColor: AppColors.primaryDark.withOpacity(0.1),
              highlightColor: AppColors.primaryDark.withOpacity(0.2),
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryDark, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // List Shimmer
            ...List.generate(4, (index) {
              return Shimmer.fromColors(
                baseColor: AppColors.primaryDark.withOpacity(0.1),
                highlightColor: AppColors.primaryDark.withOpacity(0.2),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryDark, width: 2),
                  ),
                ),
              );
            }),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(GetCategoryViewModel viewModel, AppLocalizations l10n) {
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
              l10n.failedToLoadCategories,
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
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                viewModel.fetchAllCategories();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
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

  Widget _buildEmptyWidget(AppLocalizations l10n) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_outlined,
              color: AppColors.primaryDark.withOpacity(0.5),
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              l10n.noLiveRacesAvailable,
              style: AppTextStyles.heading.copyWith(
                color: AppColors.primaryDark,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.checkBackLater,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryDark.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToRaceDetail(CategoryModel category) {
    final nav = Provider.of<NavigationController>(context, listen: false);
    nav.openRaceDetail(category);
  }
}
