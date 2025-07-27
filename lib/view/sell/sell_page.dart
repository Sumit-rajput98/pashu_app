import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pashu_app/view/sell/widget/custom_button.dart';
import 'package:pashu_app/view/sell/widget/location_section.dart';
import 'package:pashu_app/view/sell/widget/submit_and_pay_button.dart';
import 'package:pashu_app/view/sell/widget/upload_pashu_images.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/shared_pref_helper.dart';
import '../../demo.dart';
import '../../view_model/AuthVM/get_profile_view_model.dart';

class SellPashuScreen extends StatefulWidget {
  final String phoneNumber;

  const SellPashuScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<SellPashuScreen> createState() => _SellPashuScreenState();
}

class _SellPashuScreenState extends State<SellPashuScreen> {
  String? selectedType;
  String? selectedCategory;
  String? selectedGender;
  File? imageOne;
  File? imageTwo;
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final priceController = TextEditingController();
  final phoneController = TextEditingController();
  final negotiableController = TextEditingController();
  final descriptionController = TextEditingController();
  String? locationText;
  Position? position;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    // Load user profile to get wallet balance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GetProfileViewModel>(context, listen: false)
          .getProfile(widget.phoneNumber);
    });
  }

  // Localized category map
  Map<String, List<String>> getCategoryMap(AppLocalizations l10n) {
    return {
      l10n.traditionalSportsAnimal: [
        l10n.bull,
        l10n.camel,
        l10n.bird,
        l10n.pigeon,
        l10n.cock,
        l10n.dog,
        l10n.goat,
        l10n.horse,
        l10n.other,
      ],
      l10n.livestockAnimal: [
        l10n.buffalo,
        l10n.sheep,
        l10n.goat,
        l10n.pigs,
        l10n.other,
      ],
      l10n.petAnimal: [
        l10n.dog,
        l10n.cat,
        l10n.bird,
        l10n.fishes,
        l10n.smallMammals,
        l10n.other,
      ],
      l10n.farmHouseAnimal: [l10n.other],
    };
  }

  List<String> getGenderOptions(AppLocalizations l10n) => [l10n.male, l10n.female];

  Future<void> _getCurrentLocation(AppLocalizations l10n) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        locationText = l10n.locationServicesDisabled;
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        locationText = l10n.locationPermissionPermanentlyDenied;
      });
      return;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        setState(() {
          locationText = l10n.locationPermissionDenied;
        });
        return;
      }
    }

    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position!.latitude,
        position!.longitude,
      );
      SharedPrefHelper.saveLocation(position!.latitude, position!.longitude);

      if (placemarks.isNotEmpty) {
        print('Placemarks: ${position!.latitude}, ${position!.longitude}');
        Placemark place = placemarks[0];

        setState(() {
          locationText =
          '${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.postalCode ?? ''}, ${place.country ?? ''}';
        });
      } else {
        setState(() {
          locationText = l10n.unableToDetermineAddress;
        });
      }
    } catch (e) {
      setState(() {
        locationText = '${l10n.error}: $e';
      });
    }
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImageOne() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageOne = File(pickedFile.path);
      });
    }
  }

  Future<void> pickImageTwo() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageTwo = File(pickedFile.path);
      });
    }
  }

  // Validation function
  bool _validateFields(AppLocalizations l10n) {
    final List<String> missingFields = [];

    if (selectedType == null) missingFields.add(l10n.animalTypes);
    if (selectedCategory == null) missingFields.add(l10n.animalCategory);
    if (nameController.text.trim().isEmpty) missingFields.add(l10n.nameOfTheAnimal);
    if (ageController.text.trim().isEmpty) missingFields.add(l10n.enterAnimalAge);
    if (selectedGender == null) missingFields.add(l10n.selectGenderOfAnimal);
    if (priceController.text.trim().isEmpty) missingFields.add(l10n.price);
    if (negotiableController.text.trim().isEmpty) missingFields.add(l10n.negotiable);
    if (phoneController.text.trim().isEmpty) missingFields.add(l10n.yourPhoneNumber);
    if (descriptionController.text.trim().isEmpty) missingFields.add(l10n.animalDescription);
    if (locationText == null || locationText!.isEmpty) missingFields.add(l10n.getAddressForPashu);
    if (imageOne == null) missingFields.add('First Image'); // Keep as is since it's technical

    if (missingFields.isNotEmpty) {
      _showSnackBar(
        '${l10n.missingRequiredFields}: ${missingFields.join(', ')}',
        Colors.red,
      );
      return false;
    }

    // Validate phone number
    if (phoneController.text.trim().length < 10) {
      _showSnackBar(l10n.pleaseEnterValidPhoneNumber, Colors.red);
      return false;
    }

    // Validate age
    final age = int.tryParse(ageController.text.trim());
    if (age == null || age <= 0) {
      _showSnackBar(l10n.pleaseEnterValidAge, Colors.red);
      return false;
    }

    // Validate price
    final price = double.tryParse(priceController.text.trim());
    if (price == null || price <= 0) {
      _showSnackBar(l10n.pleaseEnterValidPrice, Colors.red);
      return false;
    }

    return true;
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> showSelectionModal({
    required List<String> options,
    required String title,
    required Function(String) onSelected,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.separated(
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final option = options[index];
                    return ListTile(
                      title: Text(option),
                      onTap: () {
                        Navigator.pop(context);
                        onSelected(option);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSelectorBox(String? value, String hint, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? hint,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: value == null ? Colors.grey : Colors.black,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categoryMap = getCategoryMap(l10n);
    final genderOptions = getGenderOptions(l10n);
    final types = categoryMap.keys.toList();
    final categories = categoryMap[selectedType] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<GetProfileViewModel>(
        builder: (context, profileViewModel, child) {
          final walletBalance = profileViewModel.profile?.result?.first.walletBalance ?? 0;
          final username = profileViewModel.profile?.result?.first.username ?? l10n.user;
          final userId = profileViewModel.profile?.result?.first.id ?? 0;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildHeader(l10n),

                // Wallet Balance Info
                if (profileViewModel.profile != null)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: walletBalance >= 15 ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: walletBalance >= 15 ? Colors.green.shade300 : Colors.red.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          walletBalance >= 15 ? Icons.check_circle : Icons.warning,
                          color: walletBalance >= 15 ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${l10n.walletBalance}: ₹$walletBalance',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: walletBalance >= 15 ? Colors.green.shade700 : Colors.red.shade700,
                                ),
                              ),
                              Text(
                                walletBalance >= 15
                                    ? l10n.youCanProceedWithListing
                                    : l10n.minimumRequiredToList,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: walletBalance >= 15 ? Colors.green.shade600 : Colors.red.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildLabel(l10n.animalTypes),
                      buildSelectorBox(
                        selectedType,
                        l10n.selectAnimalType,
                            () => showSelectionModal(
                          options: types,
                          title: l10n.selectAnimalType,
                          onSelected: (type) {
                            setState(() {
                              selectedType = type;
                              selectedCategory = null;
                            });
                          },
                        ),
                      ),

                      buildLabel(l10n.animalCategory),
                      buildSelectorBox(
                        selectedCategory,
                        selectedType == null
                            ? l10n.pleaseSelectAnimalTypeFirst
                            : l10n.selectAnimalCategory,
                        selectedType == null
                            ? () {}
                            : () => showSelectionModal(
                          options: categories,
                          title: l10n.selectCategory,
                          onSelected: (cat) {
                            setState(() {
                              selectedCategory = cat;
                            });
                          },
                        ),
                      ),

                      buildLabel(l10n.nameOfTheAnimal),
                      buildTextField(l10n.nameOfTheAnimal, nameController),

                      buildLabel(l10n.enterAnimalAge),
                      buildTextField(l10n.enterAnimalAge, ageController, isNumeric: true),

                      buildLabel(l10n.selectGenderOfAnimal),
                      buildSelectorBox(
                        selectedGender,
                        l10n.selectGenderOfAnimal,
                            () => showSelectionModal(
                          options: genderOptions,
                          title: l10n.selectGender,
                          onSelected: (gender) {
                            setState(() {
                              selectedGender = gender;
                            });
                          },
                        ),
                      ),

                      buildLabel(l10n.price),
                      buildTextField(l10n.price, priceController, isNumeric: true),

                      buildLabel(l10n.negotiable),
                      buildSelectorBox(
                        negotiableController.text.isEmpty ? null : negotiableController.text,
                        l10n.isPriceNegotiable,
                            () => showSelectionModal(
                          options: [l10n.yes, l10n.no],
                          title: l10n.isPriceNegotiable,
                          onSelected: (value) {
                            setState(() {
                              negotiableController.text = value;
                            });
                          },
                        ),
                      ),

                      buildLabel(l10n.yourPhoneNumber),
                      buildTextField(l10n.enterYourPhoneNumber, phoneController, isNumeric: true),

                      buildLabel(l10n.animalDescription),
                      buildMultilineTextField(l10n.enterAnimalDescription, descriptionController),

                      buildLabel(l10n.getAddressForPashu),
                      LocationSection(
                        getCurrentLocation: () => _getCurrentLocation(l10n),
                        locationText: locationText,
                      ),

                      UploadPashuImages(
                        pickImageOne: pickImageOne,
                        pickImageTwo: pickImageTwo,
                        imageOne: imageOne,
                        imageTwo: imageTwo,
                      ),

                      const SizedBox(height: 20),

                      // Enhanced Submit Button with Loading State
                      Consumer<SellPashuProvider>(
                        builder: (context, sellProvider, child) {
                          final isLoading = sellProvider.isUploading || _isSubmitting;

                          return SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: (walletBalance >= 15 && !isLoading)
                                  ? () => _handleSubmit(sellProvider, username, userId, l10n)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E4A59),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: walletBalance >= 15 ? 2 : 0,
                              ),
                              child: isLoading
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
                                    l10n.submitting,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                                  : Text(
                                walletBalance >= 15
                                    ? l10n.submitAndPay
                                    : l10n.insufficientBalance,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleSubmit(SellPashuProvider sellProvider, String username, int userId, AppLocalizations l10n) async {
    if (!_validateFields(l10n)) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await sellProvider.postPashuData(
        image1: imageOne,
        image2: imageTwo,
        animalName: nameController.text.trim(),
        breed: selectedCategory ?? l10n.other,
        price: priceController.text.trim(),
        negotiable: negotiableController.text.trim(),
        animalType: selectedType ?? '',
        animalCategory: selectedCategory ?? '',
        username: username,
        age: ageController.text.trim(),
        gender: selectedGender ?? l10n.unknown,
        description: descriptionController.text.trim(),
        phone: phoneController.text.trim(),
        referralCode: '',
        address: locationText ?? '',
        latitude: position!.latitude,
        longitude: position!.longitude,
        userId: userId.toString(),
      );

      if (sellProvider.errorMessage == null) {
        _showSnackBar(l10n.pashuListedSuccessfully, Colors.green);

        // Refresh profile to update wallet balance
        Provider.of<GetProfileViewModel>(context, listen: false)
            .getProfile(widget.phoneNumber);

        // Clear form
        _clearForm();
      } else {
        _showSnackBar(sellProvider.errorMessage!, Colors.red);
      }
    } catch (e) {
      _showSnackBar('${l10n.errorOccurred}: $e', Colors.red);
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _clearForm() {
    setState(() {
      selectedType = null;
      selectedCategory = null;
      selectedGender = null;
      imageOne = null;
      imageTwo = null;
      locationText = null;
      position = null;
    });

    nameController.clear();
    ageController.clear();
    priceController.clear();
    phoneController.clear();
    negotiableController.clear();
    descriptionController.clear();
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          children: const [
            TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMultilineTextField(String hint, TextEditingController controller) {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontWeight: FontWeight.w500),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String hint, TextEditingController controller, {bool isNumeric = false}) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontWeight: FontWeight.w500),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  Widget buildHeader(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: const Color(0xFF1E4A59),
      child: Center(
        child: Text(
          l10n.sellPashu,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
