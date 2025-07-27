import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_logo.dart';

import '../../view_model/pashuVM/pashu_insurance_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'insurance_success_screen.dart';

class PashuInsuranceFormPage extends StatefulWidget {
  const PashuInsuranceFormPage({super.key});

  @override
  State<PashuInsuranceFormPage> createState() => _PashuInsuranceFormPageState();
}

class _PashuInsuranceFormPageState extends State<PashuInsuranceFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerAddressController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _animalTypeController = TextEditingController();
  final TextEditingController _animalBreedController = TextEditingController();
  final TextEditingController _animalAgeController = TextEditingController();
  final TextEditingController _animalColorController = TextEditingController();
  final TextEditingController _animalWeightController = TextEditingController();
  final TextEditingController _healthStatusController = TextEditingController();
  final TextEditingController _additionalRemarksController =
      TextEditingController();

  // Dropdown values
  String? _selectedAnimalType;
  String? _selectedAnimalBreed;
  String? _selectedHealthStatus;

  // Animal types and breeds
  final Map<String, List<String>> _animalBreeds = {
    'Cow': ['Holstein', 'Jersey', 'Gir', 'Sahiwal', 'Red Sindhi', 'Tharparkar'],
    'Buffalo': ['Murrah', 'Nili-Ravi', 'Surti', 'Jaffarabadi', 'Mehsana'],
    'Goat': ['Beetal', 'Jamunapari', 'Barbari', 'Sirohi', 'Marwari'],
    'Sheep': ['Garole', 'Nellore', 'Rampur Bushair', 'Chokla', 'Marwari'],
    'Horse': ['Marwari', 'Kathiawari', 'Manipuri', 'Spiti', 'Zanskari'],
    'Other': ['Mixed Breed', 'Local Breed', 'Cross Breed'],
  };

  final List<String> _healthStatusOptions = [
    'Excellent',
    'Good',
    'Fair',
    'Needs Medical Attention',
    'Under Treatment',
  ];

  @override
  void dispose() {
    _ownerNameController.dispose();
    _ownerAddressController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _animalTypeController.dispose();
    _animalBreedController.dispose();
    _animalAgeController.dispose();
    _animalColorController.dispose();
    _animalWeightController.dispose();
    _healthStatusController.dispose();
    _additionalRemarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: _buildAppBar(),
      body: Consumer<AnimalInsuranceViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildInsuranceForm(viewModel),
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
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.insuranceFormTitle,
              style: AppTextStyles.heading.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.lightSage,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.15),
            Colors.blue.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.security_rounded,
              color: Colors.blue,
              size: 32,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            AppLocalizations.of(context)!.insuranceApplicationHeader,
            style: AppTextStyles.heading.copyWith(
              color: AppColors.lightSage,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          Text(
            AppLocalizations.of(context)!.insuranceApplicationSubheader,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.lightSage.withOpacity(0.8),
              fontSize: 14,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceForm(AnimalInsuranceViewModel viewModel) {
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
        border: Border.all(color: AppColors.lightSage.withOpacity(0.2)),
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
                    Icons.edit_document,
                    color: AppColors.lightSage,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.insuranceApplicationDetails,
                    style: AppTextStyles.heading.copyWith(
                      color: AppColors.lightSage,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Owner Information Section
            _buildSectionHeader(AppLocalizations.of(context)!.ownerInformation),
            const SizedBox(height: 16),

            _buildFormField(
              label: AppLocalizations.of(context)!.ownerName,
              controller: _ownerNameController,
              icon: Icons.person_rounded,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context)!.ownerNameRequired;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            _buildFormField(
              label: AppLocalizations.of(context)!.ownerAddress,
              controller: _ownerAddressController,
              icon: Icons.location_on_rounded,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context)!.ownerAddressRequired;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            _buildFormField(
              label: AppLocalizations.of(context)!.contactNumber,
              controller: _contactNumberController,
              icon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context)!.contactNumberRequired;
                }
                if (value.trim().length < 10) {
                  return AppLocalizations.of(context)!.contactNumberInvalid;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            _buildFormField(
              label: AppLocalizations.of(context)!.emailAddress,
              controller: _emailController,
              icon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context)!.emailAddressRequired;
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return AppLocalizations.of(context)!.emailAddressInvalid;
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Animal Information Section
            _buildSectionHeader(
              AppLocalizations.of(context)!.animalInformation,
            ),
            const SizedBox(height: 16),

            _buildDropdownField(
              label: AppLocalizations.of(context)!.animalType,
              value: _selectedAnimalType,
              items: _animalBreeds.keys.toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAnimalType = value;
                  _selectedAnimalBreed = null; // Reset breed when type changes
                });
              },
              icon: Icons.pets_rounded,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.animalTypeRequired;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            _buildDropdownField(
              label: AppLocalizations.of(context)!.animalBreed,
              value: _selectedAnimalBreed,
              items:
                  _selectedAnimalType != null
                      ? _animalBreeds[_selectedAnimalType!] ?? []
                      : [],
              onChanged: (value) {
                setState(() {
                  _selectedAnimalBreed = value;
                });
              },
              icon: Icons.category_rounded,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.animalBreedRequired;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            _buildFormField(
              label: AppLocalizations.of(context)!.animalAge,
              controller: _animalAgeController,
              icon: Icons.cake_rounded,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context)!.animalAgeRequired;
                }
                final age = int.tryParse(value);
                if (age == null || age <= 0) {
                  return AppLocalizations.of(context)!.animalAgeInvalid;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            _buildFormField(
              label: AppLocalizations.of(context)!.animalColor,
              controller: _animalColorController,
              icon: Icons.color_lens_rounded,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context)!.animalColorRequired;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            _buildFormField(
              label: AppLocalizations.of(context)!.animalWeight,
              controller: _animalWeightController,
              icon: Icons.monitor_weight_rounded,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context)!.animalWeightRequired;
                }
                final weight = double.tryParse(value);
                if (weight == null || weight <= 0) {
                  return AppLocalizations.of(context)!.animalWeightInvalid;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            _buildDropdownField(
              label: AppLocalizations.of(context)!.healthStatus,
              value: _selectedHealthStatus,
              items: _healthStatusOptions,
              onChanged: (value) {
                setState(() {
                  _selectedHealthStatus = value;
                });
              },
              icon: Icons.health_and_safety_rounded,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.healthStatusRequired;
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Additional Information Section
            _buildSectionHeader(
              AppLocalizations.of(context)!.additionalInformation,
            ),
            const SizedBox(height: 16),

            _buildFormField(
              label: AppLocalizations.of(context)!.additionalRemarks,
              controller: _additionalRemarksController,
              icon: Icons.note_add_rounded,
              maxLines: 4,
              validator: null, // Optional field
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    viewModel.isLoading ? null : () => _submitForm(viewModel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child:
                    viewModel.isLoading
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              AppLocalizations.of(context)!.submittingForm,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.lightSage,
                              ),
                            ),
                          ],
                        )
                        : Text(
                          AppLocalizations.of(context)!.submitForm,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppColors.lightSage,
                          ),
                        ),
              ),
            ),

            const SizedBox(height: 16),

            // Terms Note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.blue,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.insuranceTermsNote,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.blue,
                        fontSize: 11,
                        height: 1.3,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.lightSage.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.lightSage.withOpacity(0.2)),
      ),
      child: Text(
        title,
        style: AppTextStyles.heading.copyWith(
          color: AppColors.lightSage,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildFormField({
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
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.lightSage.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            children: const [
              TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.lightSage.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightSage.withOpacity(0.2)),
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

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?)? onChanged,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.lightSage.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            children: const [
              TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.lightSage.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightSage.withOpacity(0.2)),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            items:
                items
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.lightSage,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
            onChanged: onChanged,
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
            dropdownColor: AppColors.primaryDark,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.lightSage,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  void _submitForm(AnimalInsuranceViewModel viewModel) {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      _showTopSnackBar(
        AppLocalizations.of(context)!.allFieldsRequired,
        Colors.red,
      );
      return;
    }

    // Prepare form data
    final Map<String, dynamic> formData = {
      'ownerName': _ownerNameController.text.trim(),
      'ownerAddress': _ownerAddressController.text.trim(),
      'contactNumber': _contactNumberController.text.trim(),
      'email': _emailController.text.trim(),
      'animalType': _selectedAnimalType,
      'animalBreed': _selectedAnimalBreed,
      'animalAge': _animalAgeController.text.trim(),
      'animalColor': _animalColorController.text.trim(),
      'animalWeight': _animalWeightController.text.trim(),
      'healthStatus': _selectedHealthStatus,
      'remarks': _additionalRemarksController.text.trim(),
    };

    // Submit form
    viewModel.submitInsuranceForm(formData).then((_) {
      if (viewModel.success) {
        // Navigate to success screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const InsuranceSuccessScreen(),
          ),
        );
      } else if (viewModel.errorMessage != null) {
        _showTopSnackBar(viewModel.errorMessage!, Colors.red);
      }
    });
  }

  void _showTopSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 150,
          right: 20,
          left: 20,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
