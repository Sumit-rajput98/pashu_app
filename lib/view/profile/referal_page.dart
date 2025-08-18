import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pashu_app/view/profile/referal_code_container.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/app_colors.dart';
import '../../core/app_logo.dart';

class ReferralPage extends StatefulWidget {
  final String referralCode;
  final String username;
  final VoidCallback? onBack;

  const ReferralPage({
    super.key,
    required this.referralCode,
    required this.username, this.onBack,
  });

  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  String get referralUrl => 'https://pashuparivar.com/pashulink?referralCode=${widget.referralCode}';

  String getShareMessage(AppLocalizations l10n) {
    return l10n.shareMessage(widget.referralCode,referralUrl);
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light grayish-white background

      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                _buildReferralCodeCard(),
                const SizedBox(height: 25),
                _buildShareOptionsSection(),
                const SizedBox(height: 25),
                _buildBenefitsSection(),
                const SizedBox(height: 25),
                _buildHowItWorksSection(),
                 SizedBox(height: kBottomNavigationBarHeight+30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final l10n = AppLocalizations.of(context)!;

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
            l10n.referralCode,
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
              Icons.help_outline_rounded,
              color: AppColors.primaryDark,
              size: 20,
            ),
          ),
          onPressed: () {
            _showHelpDialog();
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header Icon with Animation
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withOpacity(0.15),
                    Colors.orange.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.orange, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.share_rounded,
                size: 40,
                color: Colors.orange,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            l10n.inviteEarnRewards,
            style: AppTextStyles.heading.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Subtitle
          Text(
            l10n.shareReferralDescription,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryDark.withOpacity(0.7),
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCodeCard() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.lightSage.withOpacity(0.15),
            AppColors.lightSage.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryDark, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Code Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryDark.withOpacity(0.15),
                      AppColors.primaryDark.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryDark.withOpacity(0.3)),
                ),
                child: Icon(
                  Icons.card_giftcard_rounded,
                  color: AppColors.primaryDark,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  l10n.yourReferralCode,
                  style: AppTextStyles.heading.copyWith(
                    color: AppColors.primaryDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Referral Code Display
          ReferralCodeContainer(),
        ],
      ),
    );
  }

  Widget _buildShareOptionsSection() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
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
                  Icons.share_outlined,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  l10n.shareWithFriends,
                  style: AppTextStyles.heading.copyWith(
                    color: AppColors.primaryDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Share Options Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              _buildShareOption(
                l10n.shareLink,
                Icons.link_rounded,
                Colors.green,
                    () => _shareReferralLink(),
              ),
              _buildShareOption(
                l10n.copyLink,
                Icons.copy_all_rounded,
                Colors.orange,
                    () => _copyToClipboard(referralUrl),
              ),
              _buildShareOption(
                l10n.whatsApp,
                Icons.chat_rounded,
                const Color(0xFF25D366),
                    () => _shareToWhatsApp(),
              ),
              _buildShareOption(
                l10n.moreOptions,
                Icons.more_horiz_rounded,
                Colors.purple,
                    () => _shareReferralLink(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareOption(String title, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitsSection() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
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
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  l10n.referralBenefits,
                  style: AppTextStyles.heading.copyWith(
                    color: AppColors.primaryDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Benefits List
          _buildBenefitItem(
            l10n.earnRewards,
            l10n.earnRewardsDescription,
            Icons.card_giftcard_rounded,
          ),
          _buildBenefitItem(
            l10n.helpFriends,
            l10n.helpFriendsDescription,
            Icons.people_rounded,
          ),
          _buildBenefitItem(
            l10n.unlimitedSharing,
            l10n.unlimitedSharingDescription,
            Icons.all_inclusive_rounded,
          ),
          _buildBenefitItem(
            l10n.trackProgress,
            l10n.trackProgressDescription,
            Icons.analytics_rounded,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String title, String description, IconData icon, {bool isLast = false}) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Icon(
                icon,
                color: Colors.green,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryDark.withOpacity(0.7),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Container(
            height: 1,
            margin: const EdgeInsets.only(left: 52),
            color: AppColors.primaryDark.withOpacity(0.1),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildHowItWorksSection() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.withOpacity(0.1),
            Colors.purple.withOpacity(0.05),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.help_center_rounded,
                  color: Colors.purple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  l10n.howItWorks,
                  style: AppTextStyles.heading.copyWith(
                    color: AppColors.primaryDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Steps
          _buildStep(
            '1',
            l10n.shareYourCode,
            l10n.shareYourCodeDescription,
            Colors.blue,
          ),
          _buildStep(
            '2',
            l10n.friendSignsUp,
            l10n.friendSignsUpDescription,
            Colors.orange,
          ),
          _buildStep(
            '3',
            l10n.bothGetRewards,
            l10n.bothGetRewardsDescription,
            Colors.green,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String title, String description, Color color, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step Number
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              number,
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Step Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryDark.withOpacity(0.7),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              if (!isLast) ...[
                const SizedBox(height: 20),
                Container(
                  width: 2,
                  height: 30,
                  margin: const EdgeInsets.only(left: 19),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // Share Functions
  void _shareReferralLink() async {
    final l10n = AppLocalizations.of(context)!;
    final sharePlus = SharePlus.instance;
    await sharePlus.share(
        ShareParams(title: "", text: getShareMessage(l10n))
    );
  }

  void _shareToWhatsApp() async {
    final l10n = AppLocalizations.of(context)!;
    final whatsappUrl = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(getShareMessage(l10n))}');

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    }
  }

  void _copyToClipboard(String text) {
    final l10n = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              text.length > 20 ? l10n.linkCopiedToClipboard : l10n.codeCopiedToClipboard,
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showHelpDialog() {
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
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.referralHelp,
                style: AppTextStyles.heading.copyWith(
                  color: AppColors.primaryDark,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.referralHelpContent,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryDark.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
              child: Text(
                l10n.gotIt,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
