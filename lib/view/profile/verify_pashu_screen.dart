import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pashu_app/core/shared_pref_helper.dart';
import 'package:pashu_app/view/custom_app_bar.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/app_colors.dart';
import '../../core/app_logo.dart';
import '../../core/top_snacbar.dart';

class VerifiedPashuScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const VerifiedPashuScreen({super.key, this.onBack});

  @override
  State<VerifiedPashuScreen> createState() => _VerifiedPashuScreenState();
}

class _VerifiedPashuScreenState extends State<VerifiedPashuScreen> with TickerProviderStateMixin {
  List<dynamic> pashus = [];
  bool isLoading = false;
  bool isRefreshing = false;
  int carouselIndex = 0;
  double? latitude;
  double? longitude;
  Timer? _timer;

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

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();

    fetchPashuData();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        setState(() => carouselIndex = (carouselIndex + 1) % 2);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchPashuData() async {
    final l = AppLocalizations.of(context)!;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final phone = await SharedPrefHelper.getPhoneNumber();
    latitude = 5.5;
    longitude = 7.5;

    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse('https://pashuparivar.com/api/allpashu'));
      if (response.statusCode == 200) {
        final all = jsonDecode(response.body);
        final userPashu = all.where((e) => e['usernumber'] == phone).toList();
        setState(() => pashus = userPashu);
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      TopSnackBar.show(
        context,
        message: '${l.fetchDataError}: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
        icon: Icons.error,
      );
    }

    setState(() => isLoading = false);
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;
    double dLat = (lat2 - lat1) * 3.1415926 / 180;
    double dLon = (lon2 - lon1) * 3.1415926 / 180;
    double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(lat1 * 3.1415926 / 180) *
            cos(lat2 * 3.1415926 / 180) *
            (sin(dLon / 2) * sin(dLon / 2));
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return (R * c);
  }

  Future<void> handleVerification(int id) async {
    final l = AppLocalizations.of(context)!;
    setState(() => isLoading = true);

    try {
      final profileRes = await http.get(
          Uri.parse('https://pashuparivar.com/api/getprofileByNumber/${pashus.first['usernumber']}')
      );

      if (profileRes.statusCode == 200) {
        final profile = jsonDecode(profileRes.body)['result'][0];

        if (profile['walletBalance'] >= 25) {
          await http.put(
              Uri.parse('https://pashuparivar.com/api/updatepashu/$id/verification pending')
          );

          await http.post(
            Uri.parse('https://pashuparivar.com/api/payment/deduct-wallet'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'userId': profile['id'], 'amount': 25}),
          );

          await fetchPashuData();

          TopSnackBar.show(
            context,
            message: l.verificationSuccess,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            icon: Icons.verified,
          );
        } else {
          TopSnackBar.show(
            context,
            message: l.insufficientBalance,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            icon: Icons.account_balance_wallet,
          );
        }
      }
    } catch (e) {
      TopSnackBar.show(
        context,
        message: '${l.verificationFailed}: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
        icon: Icons.error,
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildContent(l),
      ),
    );
  }

  Widget _buildContent(AppLocalizations l) {
    if (isLoading) {
      return _buildShimmerLoading(l);
    }

    if (pashus.isEmpty) {
      return _buildEmptyWidget(l);
    }

    return Column(
      children: [
        _buildInfoHeader(l),
        Expanded(
          child: SlideTransition(
            position: _slideAnimation,
            child: RefreshIndicator(
              onRefresh: fetchPashuData,
              color: AppColors.primaryDark,
              backgroundColor: Colors.white,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: pashus.length,
                itemBuilder: (context, index) {
                  return _buildPashuCard(pashus[index], index, l);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoHeader(AppLocalizations l) {
    final activeCount = pashus.where((p) => p['status'] == 'Active').length;
    final pendingCount = pashus.where((p) => p['status'] == 'verification pending').length;
    final verifiedCount = pashus.where((p) => p['status'] == 'verified pashu').length;

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
        borderRadius: BorderRadius.circular(20),
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  l.verificationStatus,
                  style: AppTextStyles.heading.copyWith(
                    color: AppColors.primaryDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildStatItem(l.active, activeCount.toString(), Colors.green),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(l.pending, pendingCount.toString(), Colors.orange),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(l.verified, verifiedCount.toString(), Colors.blue),
              ),
            ],
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
            fontSize: 18,
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

  Widget _buildPashuCard(Map<String, dynamic> pashu, int index, AppLocalizations l) {
    final dist = calculateDistance(latitude!, longitude!, 24.2, 41.4);
    final imageUrl = 'https://pashuparivar.com/uploads/${carouselIndex == 0 ? pashu['pictureOne'] : pashu['pictureTwo']}';
    final status = pashu['status'] ?? '';

    if (status == 'Active') {
      return _buildActivePashuCard(pashu, imageUrl, dist, l);
    } else if (status == 'verification pending') {
      return _buildPendingPashuCard(pashu, imageUrl, dist, l);
    } else if (status == 'verified pashu') {
      return _buildVerifiedPashuCard(pashu, imageUrl, dist, l);
    } else {
      return _buildInactiveNotice(l);
    }
  }

  Widget _buildActivePashuCard(Map<String, dynamic> pashu, String imageUrl, double dist, AppLocalizations l) {
    return Container(
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryDark,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: AppColors.lightSage.withOpacity(0.1),
                    highlightColor: AppColors.lightSage.withOpacity(0.2),
                    child: Container(
                      height: 200,
                      color: AppColors.lightSage.withOpacity(0.1),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
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
                        size: 50,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      l.active.toUpperCase(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(l.type, pashu['type'] ?? l.unknown),
                          _buildDetailRow(l.age, '${pashu['age'] ?? l.unknown} ${l.years}'),
                          _buildDetailRow(l.priceA, '₹${pashu['price'] ?? '0'}'),
                          _buildDetailRow(l.negotiable, pashu['negotiable'] == 'Yes' ? l.yes : l.no),
                          _buildDetailRow(l.owner, '${pashu['username'] ?? l.unknown}'),
                          _buildDetailRow(l.distance, '${dist.toStringAsFixed(1)} ${l.km}'),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Colors.blue,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l.verificationInfo,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.blue,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : () => handleVerification(pashu['id']),
                    icon: isLoading
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.verified_rounded),
                    label: Text(
                      isLoading ? l.processing : l.getVerified(25),
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingPashuCard(Map<String, dynamic> pashu, String imageUrl, double dist, AppLocalizations l) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.withOpacity(0.1),
            Colors.orange.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryDark,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: AppColors.lightSage.withOpacity(0.1),
                    highlightColor: AppColors.lightSage.withOpacity(0.2),
                    child: Container(
                      height: 200,
                      color: AppColors.lightSage.withOpacity(0.1),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
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
                        size: 50,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      l.verificationPending.toUpperCase(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.hourglass_empty_rounded,
                        color: Colors.orange,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.verificationUnderReview,
                        style: AppTextStyles.heading.copyWith(
                          color: Colors.orange,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.verificationReviewMessage,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.orange.withOpacity(0.8),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                _buildDetailRow(l.type, pashu['type'] ?? l.unknown),
                _buildDetailRow(l.age, '${pashu['age'] ?? l.unknown} ${l.years}'),
                _buildDetailRow(l.owner, '${pashu['username'] ?? l.unknown}'),
                _buildDetailRow(l.distance, '${dist.toStringAsFixed(1)} ${l.km}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedPashuCard(Map<String, dynamic> pashu, String imageUrl, double dist, AppLocalizations l) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.withOpacity(0.1),
            Colors.green.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryDark,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: AppColors.lightSage.withOpacity(0.1),
                    highlightColor: AppColors.lightSage.withOpacity(0.2),
                    child: Container(
                      height: 200,
                      color: AppColors.lightSage.withOpacity(0.1),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
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
                        size: 50,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 12,
                  right: 12,
                  child: Shimmer.fromColors(
                    baseColor: Colors.white,
                    highlightColor: Colors.green.shade200,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
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
                            Icons.verified_rounded,
                            color: Colors.green,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l.verified.toUpperCase(),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_rounded,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.verifiedPashu,
                              style: AppTextStyles.heading.copyWith(
                                color: Colors.green,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l.verifiedPashuMessage,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.green.withOpacity(0.8),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                _buildDetailRow(l.type, pashu['type'] ?? l.unknown),
                _buildDetailRow(l.age, '${pashu['age'] ?? l.unknown} ${l.years}'),
                _buildDetailRow(l.priceA, '₹${pashu['price'] ?? '0'}'),
                _buildDetailRow(l.negotiable, pashu['negotiable'] == 'Yes' ? l.yes : l.no),
                _buildDetailRow(l.owner, '${pashu['username'] ?? l.unknown}'),
                _buildDetailRow(l.distance, '${dist.toStringAsFixed(1)} ${l.km}'),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      TopSnackBar.show(
                        context,
                        message: l.moreDetailsComing,
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                        icon: Icons.info,
                      );
                    },
                    icon: const Icon(Icons.info_rounded),
                    label: Text(
                      l.moreDetails,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInactiveNotice(AppLocalizations l) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.withOpacity(0.1),
            Colors.grey.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryDark.withOpacity(0.3),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              l.onlyActiveCanBeVerified,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryDark.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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
                color: AppColors.primaryDark.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryDark,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading(AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: AppColors.lightSage.withOpacity(0.1),
            highlightColor: AppColors.lightSage.withOpacity(0.2),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryDark, width: 2),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: AppColors.lightSage.withOpacity(0.1),
                  highlightColor: AppColors.lightSage.withOpacity(0.2),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primaryDark, width: 2),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(AppLocalizations l) {
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
              l.emptyListTitle,
              style: AppTextStyles.heading.copyWith(
                color: AppColors.primaryDark,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l.emptyListMessage,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryDark.withOpacity(0.7),
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 30),

          ],
        ),
      ),
    );
  }
}