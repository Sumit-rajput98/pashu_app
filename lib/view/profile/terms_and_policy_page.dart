import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


import '../../core/app_colors.dart';
import '../../core/app_logo.dart';

class TermsPrivacyPage extends StatefulWidget {
  final VoidCallback? onBack;
  const TermsPrivacyPage({super.key, this.onBack});

  @override
  State<TermsPrivacyPage> createState() => _TermsPrivacyPageState();
}

class _TermsPrivacyPageState extends State<TermsPrivacyPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _showTerms = true; // true for Terms, false for Privacy Policy

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
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
        child: Column(
          children: [
            _buildToggleSection(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _showTerms ? _buildTermsContent() : _buildPrivacyContent(),
                ),
              ),
            ),
            const SizedBox(height: kBottomNavigationBarHeight + 30),
          ],
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
            l10n.termsAndPrivacy,
            style: AppTextStyles.heading.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSection() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
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
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showTerms = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: _showTerms
                      ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryDark,
                      AppColors.primaryDark.withOpacity(0.8),
                    ],
                  )
                      : null,
                  color: _showTerms ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _showTerms
                      ? [
                    BoxShadow(
                      color: AppColors.primaryDark.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.article_rounded,
                      color: _showTerms ? Colors.white : AppColors.primaryDark,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.termsOfService,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: _showTerms ? Colors.white : AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showTerms = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: !_showTerms
                      ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryDark,
                      AppColors.primaryDark.withOpacity(0.8),
                    ],
                  )
                      : null,
                  color: !_showTerms ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !_showTerms
                      ? [
                    BoxShadow(
                      color: AppColors.primaryDark.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.privacy_tip_rounded,
                      color: !_showTerms ? Colors.white : AppColors.primaryDark,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.privacyPolicy,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: !_showTerms ? Colors.white : AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsContent() {
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
          // Header
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
                  Icons.article_rounded,
                  color: AppColors.primaryDark,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.termsOfService,
                      style: AppTextStyles.heading.copyWith(
                        color: AppColors.primaryDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      l10n.lastUpdated,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryDark.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Terms Content
          _buildSection(
            l10n.acceptanceOfTerms,
            l10n.acceptanceOfTermsContent,
          ),

          _buildSection(
            l10n.useLicense,
            l10n.useLicenseContent,
          ),

          _buildSection(
            l10n.userResponsibilities,
            l10n.userResponsibilitiesContent,
          ),

          _buildSection(
            l10n.platformServices,
            l10n.platformServicesContent,
          ),

          _buildSection(
            l10n.accountSecurity,
            l10n.accountSecurityContent,
          ),

          _buildSection(
            l10n.paymentTerms,
            l10n.paymentTermsContent,
          ),

          _buildSection(
            l10n.contentGuidelines,
            l10n.contentGuidelinesContent,
          ),

          _buildSection(
            l10n.limitationOfLiability,
            l10n.limitationOfLiabilityContent,
          ),

          _buildSection(
            l10n.modifications,
            l10n.modificationsContent,
          ),

          _buildSection(
            l10n.contactInformation,
            l10n.contactInformationContent,
            isLast: true,
          ),
        ],

      ),
    );
  }

  Widget _buildPrivacyContent() {
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
          // Header
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
                  Icons.privacy_tip_rounded,
                  color: AppColors.primaryDark,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.privacyPolicy,
                      style: AppTextStyles.heading.copyWith(
                        color: AppColors.primaryDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      l10n.lastUpdated,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryDark.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Privacy Content
          _buildSection(
            l10n.informationWeCollect,
            l10n.informationWeCollectContent,
          ),

          _buildSection(
            l10n.howWeUseYourInformation,
            l10n.howWeUseYourInformationContent,
          ),

          _buildSection(
            l10n.informationSharing,
            l10n.informationSharingContent,
          ),

          _buildSection(
            l10n.dataSecurity,
            l10n.dataSecurityContent,
          ),

          _buildSection(
            l10n.dataRetention,
            l10n.dataRetentionContent,
          ),

          _buildSection(
            l10n.yourRights,
            l10n.yourRightsContent,
          ),

          _buildSection(
            l10n.cookiesAndTracking,
            l10n.cookiesAndTrackingContent,
          ),

          _buildSection(
            l10n.thirdPartyServices,
            l10n.thirdPartyServicesContent,
          ),

          _buildSection(
            l10n.childrensPrivacy,
            l10n.childrensPrivacyContent,
          ),

          _buildSection(
            l10n.changesToThisPolicy,
            l10n.changesToThisPolicyContent,
          ),

          _buildSection(
            l10n.contactUs,
            l10n.privacyContactContent,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, {bool isLast = false}) {
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

        const SizedBox(height: 8),

        Text(
          content,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primaryDark.withOpacity(0.8),
            fontSize: 14,
            height: 1.6,
          ),
        ),

        if (!isLast) ...[
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: AppColors.primaryDark.withOpacity(0.1),
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}

