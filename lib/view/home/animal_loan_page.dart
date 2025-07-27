import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_logo.dart';

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

  // Dropdown options
  final List<String> _repaymentPeriods = [
    '6 months',
    '12 months',
    '18 months',
    '24 months',
    '36 months',
    '48 months',
    '60 months',
  ];

  final List<String> _incomeSources = [
    'Agriculture',
    'Livestock Farming',
    'Dairy Business',
    'Small Business',
    'Salaried Job',
    'Self Employment',
    'Other',
  ];

  final List<String> _loanPurposes = [
    'Purchase New Animals',
    'Animal Feed & Nutrition',
    'Veterinary Treatment',
    'Farm Equipment',
    'Shelter Construction',
    'Breeding Program',
    'Business Expansion',
    'Other',
  ];

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
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: _buildAppBar(),
      body: Consumer<AnimalLoanViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildLoanForm(viewModel),
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
              'Pashu Loan Form',
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
            Colors.green.withOpacity(0.15),
            Colors.green.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              color: Colors.green,
              size: 32,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Animal Loan Application',
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
            'Get financial support for your livestock farming needs',
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

  Widget _buildLoanForm(AnimalLoanViewModel viewModel) {
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
                    Icons.edit_document,
                    color: AppColors.lightSage,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Loan Application Details',
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

            // Applicant Information Section
            _buildSectionHeader('Applicant Information'),
            const SizedBox(height: 16),

            _buildFormField(
              label: 'Applicant Name',
              controller: _applicantNameController,
              icon: Icons.person_rounded,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Applicant name is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            _buildFormField(
              label: 'Applicant Address',
              controller: _applicantAddressController,
              icon: Icons.location_on_rounded,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Applicant address is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            _buildFormField(
              label: 'Contact Number',
              controller: _contactNumberController,
              icon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Contact number is required';
                }
                if (value.trim().length < 10) {
                  return 'Please enter a valid contact number';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            _buildFormField(
              label: 'Email Address',
              controller: _emailController,
              icon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email address is required';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Loan Information Section
            _buildSectionHeader('Loan Information'),
            const SizedBox(height: 16),

            _buildFormField(
              label: 'Loan Amount (₹)',
              controller: _loanAmountController,
              icon: Icons.currency_rupee_rounded,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Loan amount is required';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid loan amount';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            _buildDropdownField(
              label: 'Repayment Period',
              value: _selectedRepaymentPeriod,
              items: _repaymentPeriods,
              onChanged: (value) {
                setState(() {
                  _selectedRepaymentPeriod = value;
                });
              },
              icon: Icons.schedule_rounded,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Repayment period is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            _buildDropdownField(
              label: 'Income Source',
              value: _selectedIncomeSource,
              items: _incomeSources,
              onChanged: (value) {
                setState(() {
                  _selectedIncomeSource = value;
                });
              },
              icon: Icons.work_rounded,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Income source is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            _buildDropdownField(
              label: 'Purpose of Loan',
              value: _selectedLoanPurpose,
              items: _loanPurposes,
              onChanged: (value) {
                setState(() {
                  _selectedLoanPurpose = value;
                });
              },
              icon: Icons.backup_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Purpose of loan is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Additional Information Section
            _buildSectionHeader('Additional Information'),
            const SizedBox(height: 16),

            _buildFormField(
              label: 'Additional Remarks',
              controller: _additionalRemarksController,
              icon: Icons.note_add_rounded,
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Additional remarks are required';
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
                onPressed: viewModel.isLoading ? null : () => _submitForm(viewModel),
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
                      'Submitting Form...',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.lightSage,
                      ),
                    ),
                  ],
                )
                    : Text(
                  'Submit Form',
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
                border: Border.all(
                  color: Colors.blue.withOpacity(0.2),
                ),
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
                      'By submitting this form, you agree to our loan terms and conditions. Our team will review your application and contact you within 3-5 business days with loan approval status.',
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
        border: Border.all(
          color: AppColors.lightSage.withOpacity(0.2),
        ),
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
            color: AppColors.lightSage.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.lightSage.withOpacity(0.2),
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            items: items.map((item) => DropdownMenuItem<String>(
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
            )).toList(),
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

  void _submitForm(AnimalLoanViewModel viewModel) {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      _showTopSnackBar('All fields are required', Colors.red);
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
          MaterialPageRoute(
            builder: (context) => const LoanSuccessScreen(),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
