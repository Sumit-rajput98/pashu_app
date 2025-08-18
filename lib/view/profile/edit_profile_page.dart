import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/app_colors.dart';
import '../../core/app_logo.dart';
import '../../model/auth/profile_model.dart';
import '../../view_model/AuthVM/get_profile_view_model.dart';
import '../../view_model/AuthVM/update_profile_view_model.dart';

class EditProfilePage extends StatefulWidget {
  final Result userProfile;
  final String phoneNumber;
  final VoidCallback? onBack;

  const EditProfilePage({
    super.key,
    required this.userProfile,
    required this.phoneNumber, this.onBack,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userProfile.username ?? '');
    _emailController = TextEditingController(text: widget.userProfile.emailid?.toString() ?? '');
    _addressController = TextEditingController(text: widget.userProfile.address ?? '');

    // Listen to changes
    _nameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _addressController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {
      _hasChanges = _nameController.text != (widget.userProfile.username ?? '') ||
          _emailController.text != (widget.userProfile.emailid?.toString() ?? '') ||
          _addressController.text != (widget.userProfile.address ?? '');
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light grayish-white background

      body: Consumer<UpdateProfileViewModel>(
        builder: (context, updateViewModel, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Display Section
                  _buildProfileDisplaySection(l10n),

                  const SizedBox(height: 30),

                  // Edit Profile Form
                  _buildEditProfileForm(updateViewModel, l10n),

                  SizedBox(height: kBottomNavigationBarHeight + 30),
                ],
              ),
            ),
          );
        },
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
            l10n.editProfile,
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

  Widget _buildProfileDisplaySection(AppLocalizations l10n) {
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
                  Icons.person_outline_rounded,
                  color: AppColors.primaryDark,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                l10n.profileDetailsSectionHeader,
                style: AppTextStyles.heading.copyWith(
                  color: AppColors.primaryDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Profile Info Rows
          _buildInfoRow(
            l10n.fullName,
            widget.userProfile.username ?? l10n.notProvided,
            Icons.person_rounded,
          ),
          _buildInfoRow(
            l10n.phoneNumber,
            widget.userProfile.number ?? l10n.notProvided,
            Icons.phone_rounded,
          ),
          _buildInfoRow(
            l10n.emailAddress,
            widget.userProfile.emailid?.toString() ?? l10n.notProvided,
            Icons.email_rounded,
          ),
          _buildInfoRow(
            l10n.address,
            widget.userProfile.address ?? l10n.notProvided,
            Icons.location_on_rounded,
          ),
          _buildInfoRow(
            l10n.referralCode,
            widget.userProfile.referralcode ?? l10n.notAvailable,
            Icons.share_rounded,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {bool isLast = false}) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: AppColors.primaryDark.withOpacity(0.6),
              size: 16,
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryDark.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
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
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.end,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: AppColors.primaryDark.withOpacity(0.1),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildEditProfileForm(UpdateProfileViewModel updateViewModel, AppLocalizations l10n) {
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form Header
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
                    Icons.edit_rounded,
                    color: AppColors.primaryDark,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    l10n.editProfileInformation,
                    style: AppTextStyles.heading.copyWith(
                      color: AppColors.primaryDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Editable Name Field
            _buildEditableField(
              label: l10n.fullName,
              controller: _nameController,
              icon: Icons.person_rounded,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.nameCannotBeEmpty;
                }
                if (value.trim().length < 2) {
                  return l10n.nameMinimumCharacters;
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Non-editable Phone Field
            _buildNonEditableField(
              label: l10n.phoneNumber,
              value: widget.userProfile.number ?? l10n.notProvided,
              icon: Icons.phone_rounded,
            ),

            const SizedBox(height: 20),

            // Editable Email Field
            _buildEditableField(
              label: l10n.emailAddress,
              controller: _emailController,
              icon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return l10n.pleaseEnterValidEmail;
                  }
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Editable Address Field
            _buildEditableField(
              label: l10n.address,
              controller: _addressController,
              icon: Icons.location_on_rounded,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.addressCannotBeEmpty;
                }
                if (value.trim().length < 10) {
                  return l10n.pleaseEnterCompleteAddress;
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Non-editable Referral Code Field
            _buildNonEditableField(
              label: l10n.referralCode,
              value: widget.userProfile.referralcode ?? l10n.notAvailable,
              icon: Icons.share_rounded,
            ),

            const SizedBox(height: 30),

            // Update Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: (_hasChanges && !updateViewModel.isLoading)
                    ? () => _handleUpdateProfile(updateViewModel)
                    : null,
                icon: updateViewModel.isLoading
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.save_rounded),
                label: Text(
                  updateViewModel.isLoading
                      ? l10n.updatingProfile
                      : l10n.updateProfile,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_hasChanges && !updateViewModel.isLoading)
                      ? AppColors.primaryDark
                      : Colors.grey,
                  foregroundColor: Colors.white,
                  elevation: (_hasChanges && !updateViewModel.isLoading) ? 4 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info Note
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
                      l10n.phoneAndReferralNotChangeable,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.blue,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primaryDark.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryDark.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.primaryDark,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: AppColors.primaryDark.withOpacity(0.6),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildNonEditableField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primaryDark.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryDark.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.primaryDark.withOpacity(0.5),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primaryDark.withOpacity(0.6),
                    fontSize: 16,
                  ),
                ),
              ),
              Icon(
                Icons.lock_outline_rounded,
                color: AppColors.primaryDark.withOpacity(0.4),
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleUpdateProfile(UpdateProfileViewModel updateViewModel) async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updateData = <String, dynamic>{
      'username': _nameController.text.trim(),
      'emailid': _emailController.text.trim(),
      'address': _addressController.text.trim(),
    };

    await updateViewModel.updateProfile(
      widget.userProfile.id.toString(),
      updateData,
    );

    if (updateViewModel.message == "Profile updated successfully") {
      _showSuccessDialog(l10n);

      // Refresh profile data
      Provider.of<GetProfileViewModel>(context, listen: false)
          .getProfile(widget.phoneNumber);
    } else {
      _showErrorDialog(updateViewModel.message ?? l10n.updateFailed, l10n);
    }
  }

  // void _showSuccessDialog(AppLocalizations l10n) {
  //   showDialog(
  //       context: context,
  //       barrierDismissible

  void _showSuccessDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppColors.primaryDark, width: 2),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 48,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                l10n.profileUpdatedSuccessfully,
                style: AppTextStyles.heading.copyWith(
                  color: AppColors.primaryDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                l10n.profileUpdateSuccessMessage,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryDark.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to profile page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:  Text(l10n.continueA),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message,AppLocalizations l10n) {
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
                  Icons.error_outline_rounded,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.updateFailed,
                style: AppTextStyles.heading.copyWith(
                  color: AppColors.primaryDark,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryDark.withOpacity(0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(
                l10n.ok,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.red,
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
