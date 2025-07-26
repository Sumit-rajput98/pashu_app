import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_logo.dart';
import '../../model/auth/profile_model.dart';
import '../../view_model/AuthVM/get_profile_view_model.dart';
import '../../view_model/AuthVM/update_profile_view_model.dart';


class EditProfilePage extends StatefulWidget {
  final Result userProfile;
  final String phoneNumber;

  const EditProfilePage({
    super.key,
    required this.userProfile,
    required this.phoneNumber,
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
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: _buildAppBar(),
      body: Consumer<UpdateProfileViewModel>(
        builder: (context, updateViewModel, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Display Section
                  _buildProfileDisplaySection(),

                  const SizedBox(height: 30),

                  // Edit Profile Form
                  _buildEditProfileForm(updateViewModel),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryDark,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.lightSage.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
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
            'Edit Profile',
            style: AppTextStyles.heading.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.lightSage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDisplaySection() {
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
        border: Border.all(
          color: AppColors.lightSage.withOpacity(0.3),
        ),
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
                  color: AppColors.lightSage.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.lightSage,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Profile Details',
                style: AppTextStyles.heading.copyWith(
                  color: AppColors.lightSage,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Profile Info Rows
          _buildInfoRow(
            'Full Name',
            widget.userProfile.username ?? 'Not provided',
            Icons.person_rounded,
          ),
          _buildInfoRow(
            'Phone Number',
            widget.userProfile.number ?? 'Not provided',
            Icons.phone_rounded,
          ),
          _buildInfoRow(
            'Email Address',
            widget.userProfile.emailid?.toString() ?? 'Not provided',
            Icons.email_rounded,
          ),
          _buildInfoRow(
            'Address',
            widget.userProfile.address ?? 'Not provided',
            Icons.location_on_rounded,
          ),
          _buildInfoRow(
            'Referral Code',
            widget.userProfile.referralcode ?? 'Not available',
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
              color: AppColors.lightSage.withOpacity(0.7),
              size: 16,
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.lightSage.withOpacity(0.8),
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
                  color: AppColors.lightSage,
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
            color: AppColors.lightSage.withOpacity(0.1),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildEditProfileForm(UpdateProfileViewModel updateViewModel) {
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
          color: AppColors.lightSage.withOpacity(0.2),
        ),
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
                    color: AppColors.lightSage.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    color: AppColors.lightSage,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Edit Profile Information',
                    style: AppTextStyles.heading.copyWith(
                      color: AppColors.lightSage,
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
              label: 'Full Name',
              controller: _nameController,
              icon: Icons.person_rounded,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name cannot be empty';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Non-editable Phone Field
            _buildNonEditableField(
              label: 'Phone Number',
              value: widget.userProfile.number ?? 'Not provided',
              icon: Icons.phone_rounded,
            ),

            const SizedBox(height: 20),

            // Editable Email Field
            _buildEditableField(
              label: 'Email Address',
              controller: _emailController,
              icon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Editable Address Field
            _buildEditableField(
              label: 'Address',
              controller: _addressController,
              icon: Icons.location_on_rounded,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Address cannot be empty';
                }
                if (value.trim().length < 10) {
                  return 'Please enter a complete address';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Non-editable Referral Code Field
            _buildNonEditableField(
              label: 'Referral Code',
              value: widget.userProfile.referralcode ?? 'Not available',
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
                      ? 'Updating Profile...'
                      : 'Update Profile',
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
                      'Note: Phone number and referral code cannot be changed. Only name, email, and address can be updated.',
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
            color: AppColors.lightSage.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.lightSage.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.lightSage.withOpacity(0.2),
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.lightSage,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: AppColors.lightSage.withOpacity(0.6),
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
            color: AppColors.lightSage.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.lightSage.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.lightSage.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.lightSage.withOpacity(0.5),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.lightSage.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
              ),
              Icon(
                Icons.lock_outline_rounded,
                color: AppColors.lightSage.withOpacity(0.4),
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleUpdateProfile(UpdateProfileViewModel updateViewModel) async {
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
      _showSuccessDialog();

      // Refresh profile data
      Provider.of<GetProfileViewModel>(context, listen: false)
          .getProfile(widget.phoneNumber);
    } else {
      _showErrorDialog(updateViewModel.message ?? "Failed to update profile");
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.lightSage,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 48,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Profile Updated Successfully!',
                style: AppTextStyles.heading.copyWith(
                  color: AppColors.primaryDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                'Your profile information has been updated successfully.',
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
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.lightSage,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Update Failed',
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
              child: Text(
                'OK',
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
