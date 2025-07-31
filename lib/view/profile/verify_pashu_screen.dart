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

import '../../core/app_colors.dart';
import '../../core/app_logo.dart';
import '../../core/top_snacbar.dart';

class VerifiedPashuScreen extends StatefulWidget {
  const VerifiedPashuScreen({super.key});

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final phone = await SharedPrefHelper.getPhoneNumber();
    latitude = 5.5;
    longitude = 7.5;
    print(latitude);
    print(longitude);

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
        message: 'Failed to load data: $e',
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
            message: 'Verification request submitted successfully!',
            backgroundColor: Colors.green,
            textColor: Colors.white,
            icon: Icons.verified,
          );
        } else {
          TopSnackBar.show(
            context,
            message: 'Insufficient wallet balance. Minimum ₹25 required.',
            backgroundColor: Colors.red,
            textColor: Colors.white,
            icon: Icons.account_balance_wallet,
          );
        }
      }
    } catch (e) {
      TopSnackBar.show(
        context,
        message: 'Verification failed: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
        icon: Icons.error,
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light grayish-white background
      appBar: CustomAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildContent(),
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
          Expanded(
            child: Text(
              'Verify Your Pashu',
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
          onPressed: fetchPashuData,
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return _buildShimmerLoading();
    }

    if (pashus.isEmpty) {
      return _buildEmptyWidget();
    }

    return Column(
      children: [
        _buildInfoHeader(),
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
                  return _buildPashuCard(pashus[index], index);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoHeader() {
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
                  'Verification Status',
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
                child: _buildStatItem('Active', activeCount.toString(), Colors.green),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem('Pending', pendingCount.toString(), Colors.orange),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem('Verified', verifiedCount.toString(), Colors.blue),
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

  Widget _buildPashuCard(Map<String, dynamic> pashu, int index) {
    final dist = calculateDistance(latitude!, longitude!, 24.2, 41.4);
    final imageUrl = 'https://pashuparivar.com/uploads/${carouselIndex == 0 ? pashu['pictureOne'] : pashu['pictureTwo']}';
    final status = pashu['status'] ?? '';

    if (status == 'Active') {
      return _buildActivePashuCard(pashu, imageUrl, dist);
    } else if (status == 'verification pending') {
      return _buildPendingPashuCard(pashu, imageUrl, dist);
    } else if (status == 'verified pashu') {
      return _buildVerifiedPashuCard(pashu, imageUrl, dist);
    } else {
      return _buildInactiveNotice();
    }
  }

  Widget _buildActivePashuCard(Map<String, dynamic> pashu, String imageUrl, double dist) {
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
                      'ACTIVE',
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
                          _buildDetailRow('Type', pashu['type'] ?? 'Unknown'),
                          _buildDetailRow('Age', '${pashu['age'] ?? 'Unknown'} years'),
                          _buildDetailRow('Price', '₹${pashu['price'] ?? '0'}'),
                          _buildDetailRow('Negotiable', pashu['negotiable'] ?? 'No'),
                          _buildDetailRow('Owner', '${pashu['username'] ?? 'Unknown'} ji'),
                          _buildDetailRow('Distance', '${dist.toStringAsFixed(1)} km'),
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
                          'Get your pashu verified for better visibility and trust',
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
                      isLoading ? 'Processing...' : 'Get Verified (₹25)',
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

  Widget _buildPendingPashuCard(Map<String, dynamic> pashu, String imageUrl, double dist) {
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
                      'VERIFICATION PENDING',
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
                        'Verification Under Review',
                        style: AppTextStyles.heading.copyWith(
                          color: Colors.orange,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Our team is reviewing your submission',
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

                _buildDetailRow('Type', pashu['type'] ?? 'Unknown'),
                _buildDetailRow('Age', '${pashu['age'] ?? 'Unknown'} years'),
                _buildDetailRow('Owner', '${pashu['username'] ?? 'Unknown'} ji'),
                _buildDetailRow('Distance', '${dist.toStringAsFixed(1)} km'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedPashuCard(Map<String, dynamic> pashu, String imageUrl, double dist) {
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
                            'VERIFIED',
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
                              'Verified Pashu',
                              style: AppTextStyles.heading.copyWith(
                                color: Colors.green,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'This animal has been verified by our team',
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

                _buildDetailRow('Type', pashu['type'] ?? 'Unknown'),
                _buildDetailRow('Age', '${pashu['age'] ?? 'Unknown'} years'),
                _buildDetailRow('Price', '₹${pashu['price'] ?? '0'}'),
                _buildDetailRow('Negotiable', pashu['negotiable'] ?? 'No'),
                _buildDetailRow('Owner', '${pashu['username'] ?? 'Unknown'} ji'),
                _buildDetailRow('Distance', '${dist.toStringAsFixed(1)} km'),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      TopSnackBar.show(
                        context,
                        message: 'More details coming soon!',
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                        icon: Icons.info,
                      );
                    },
                    icon: const Icon(Icons.info_rounded),
                    label: Text(
                      'More Details',
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

  Widget _buildInactiveNotice() {
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
              '💡 Only Active Pashu Can Be Verified',
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

  Widget _buildShimmerLoading() {
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

  Widget _buildEmptyWidget() {
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
              'Your List is Empty',
              style: AppTextStyles.heading.copyWith(
                color: AppColors.primaryDark,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You haven\'t added any Pashu yet. Start exploring to add what you love!',
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
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add New Pashu'),
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
}
