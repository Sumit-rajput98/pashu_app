import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_logo.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../view_model/pashuVM/animal_loan_view_model.dart';
import 'loan_success_page.dart';

class PashuLoanFormPage extends StatefulWidget {
  const PashuLoanFormPage({super.key});

  @override
  State<PashuLoanFormPage> createState() => _PashuLoanFormPageState();
}

class _PashuLoanFormPageState extends State<PashuLoanFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final TextEditingController _applicantNameController = TextEditingController();
  final TextEditingController _applicantAddressController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _repaymentPeriodController = TextEditingController();
  final TextEditingController _incomeSourceController = TextEditingController();
  final TextEditingController _purposeOfLoanController = TextEditingController();
  final TextEditingController _additionalRemarksController = TextEditingController();
  final TextEditingController _loanAmountController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Dropdown values
  String? _selectedRepaymentPeriod;
  String? _selectedIncomeSource;
  String? _selectedLoanPurpose;

  // Dropdown options using localized strings
  List<String> get _repaymentPeriods {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.sixMonths,
      l10n.twelveMonths,
      l10n.eighteenMonths,
      l10n.twentyFourMonths,
      l10n.thirtySixMonths,
      l10n.fortyEightMonths,
      l10n.sixtyMonths,
    ];
  }

  List<String> get _incomeSources {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.agriculture,
      l10n.livestockFarming,
      l10n.dairyBusiness,
      l10n.smallBusiness,
      l10n.salariedJob,
      l10n.selfEmployment,
      l10n.other,
    ];
  }

  List<String> get _loanPurposes {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.purchaseNewAnimals,
      l10n.animalFeedNutrition,
      l10n.veterinaryTreatment,
      l10n.farmEquipment,
      l10n.shelterConstruction,
      l10n.breedingProgram,
      l10n.businessExpansion,
      l10n.other,
    ];
  }

  @override
  void dispose() {
    _applicantNameController.dispose();
    _applicantAddressController.dispose();
    _contactNumberController.dispose();
    _repaymentPeriodController.dispose();
    _incomeSourceController.dispose();
    _purposeOfLoanController.dispose();
    _additionalRemarksController.dispose();
    _loanAmountController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light grayish-white background

      body: Consumer<AnimalLoanViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildHeader(l10n),
                  const SizedBox(height: 24),
                  _buildLoanForm(viewModel, l10n),
                  const SizedBox(height: kBottomNavigationBarHeight+20),
                ],
              ),
            ),
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
          Expanded(
            child: Text(
              l10n.loanFormTitle,
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
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              color: Colors.green,
              size: 32,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            l10n.loanApplicationHeader,
            style: AppTextStyles.heading.copyWith(
              color: AppColors.primaryDark,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          Text(
            l10n.loanApplicationSubheader,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryDark.withOpacity(0.7),
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

  Widget _buildLoanForm(AnimalLoanViewModel viewModel, AppLocalizations l10n) {
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
        border: Border.all(color: AppColors.primaryDark, width: 2),
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
                    Icons.edit_document,
                    color: AppColors.primaryDark,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    l10n.loanApplicationDetails,
                    style: AppTextStyles.heading.copyWith(
                      color: AppColors.primaryDark,
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

            // Applicant Information Section
            _buildSectionHeader(l10n.applicantInformation),
            const SizedBox(height: 16),

            _buildFormField(
              label: l10n.applicantName,
              controller: _applicantNameController,
              icon: Icons.person_rounded,
              l10n: l10n,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.applicantNameRequired;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            _buildFormField(
              label: l10n.applicantAddress,
              controller: _applicantAddressController,
              icon: Icons.location_on_rounded,
              maxLines: 3,
              l10n: l10n,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.applicantAddressRequired;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            _buildFormField(
              label: l10n.contactNumber,
              controller: _contactNumberController,
              icon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
              l10n: l10n,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.contactNumberRequired;
                }
                if (value.trim().length < 10) {
                  return l10n.contactNumberInvalid;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            _buildFormField(
              label: l10n.emailAddress,
              controller: _emailController,
              icon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
              l10n: l10n,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.emailAddressRequired;
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return l10n.emailAddressInvalid;
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Loan Information Section
            _buildSectionHeader(l10n.loanInformation),
            const SizedBox(height: 16),

            _buildFormField(
              label: l10n.loanAmount,
              controller: _loanAmountController,
              icon: Icons.currency_rupee_rounded,
              keyboardType: TextInputType.number,
              l10n: l10n,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.loanAmountRequired;
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return l10n.loanAmountInvalid;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            _buildDropdownField(
              label: l10n.repaymentPeriod,
              value: _selectedRepaymentPeriod,
              items: _repaymentPeriods,
              onChanged: (value) {
                setState(() {
                  _selectedRepaymentPeriod = value;
                });
              },
              icon: Icons.schedule_rounded,
              l10n: l10n,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.repaymentPeriodRequired;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            _buildDropdownField(
              label: l10n.incomeSource,
              value: _selectedIncomeSource,
              items: _incomeSources,
              onChanged: (value) {
                setState(() {
                  _selectedIncomeSource = value;
                });
              },
              icon: Icons.work_rounded,
              l10n: l10n,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.incomeSourceRequired;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            _buildDropdownField(
              label: l10n.purposeOfLoan,
              value: _selectedLoanPurpose,
              items: _loanPurposes,
              onChanged: (value) {
                setState(() {
                  _selectedLoanPurpose = value;
                });
              },
              icon: Icons.backup_outlined,
              l10n: l10n,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.purposeOfLoanRequired;
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Additional Information Section
            _buildSectionHeader(l10n.additionalInformation),
            const SizedBox(height: 16),

            _buildFormField(
              label: l10n.additionalRemarks,
              controller: _additionalRemarksController,
              icon: Icons.note_add_rounded,
              maxLines: 4,
              l10n: l10n,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.additionalRemarksRequired;
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: viewModel.isLoading ? null : () => _submitForm(viewModel, l10n),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: viewModel.isLoading
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
                      l10n.submittingForm,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
                    : Text(
                  l10n.submitForm,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
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
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
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
                      l10n.loanTermsNote,
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark.withOpacity(0.1),
            AppColors.primaryDark.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryDark.withOpacity(0.3)),
      ),
      child: Text(
        title,
        style: AppTextStyles.heading.copyWith(
          color: AppColors.primaryDark,
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
    required AppLocalizations l10n,
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
              color: AppColors.primaryDark.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryDark.withOpacity(0.3)),
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

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?)? onChanged,
    required IconData icon,
    required AppLocalizations l10n,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryDark.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryDark.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            items: items
                .map(
                  (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primaryDark,
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
            dropdownColor: Colors.white,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.primaryDark,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  void _submitForm(AnimalLoanViewModel viewModel, AppLocalizations l10n) {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      _showTopSnackBar(
        l10n.allFieldsRequired,
        Colors.red,
        l10n,
      );
      return;
    }

    // Prepare form data
    final Map<String, dynamic> formData = {
      'applicantName': _applicantNameController.text.trim(),
      'applicantAddress': _applicantAddressController.text.trim(),
      'contactNumber': _contactNumberController.text.trim(),
      'email': _emailController.text.trim(),
      'animalType': 'abc',
      'animalBreed': 'abc',
      'applicantPanCardNumber': 'PASHU123456',
      'applicantAadharNumber': '345678901234',
      'loanAmount': _loanAmountController.text.trim(),
      'repaymentPeriod': _selectedRepaymentPeriod,
      'incomeSource': _selectedIncomeSource,
      'purposeOfLoan': _selectedLoanPurpose,
      'remarks': _additionalRemarksController.text.trim(),
    };

    // Submit form
    viewModel.submitLoanForm(formData).then((_) {
      if (viewModel.success) {
        // Navigate to success screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoanSuccessScreen()),
        );
      } else if (viewModel.errorMessage != null) {
        _showTopSnackBar(viewModel.errorMessage!, Colors.red, l10n);
      }
    });
  }

  void _showTopSnackBar(String message, Color backgroundColor, AppLocalizations l10n) {
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
