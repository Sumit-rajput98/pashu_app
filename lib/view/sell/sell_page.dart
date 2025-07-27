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

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        locationText = 'Location services are disabled';
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        locationText = 'Location permission permanently denied';
      });
      return;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        setState(() {
          locationText = 'Location permission denied';
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

      if (placemarks.isNotEmpty) {
        print('Placemarks: ${position!.latitude}, ${position!.longitude}');
        Placemark place = placemarks[0];

        setState(() {
          locationText =
          '${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.postalCode ?? ''}, ${place.country ?? ''}';
        });
      } else {
        setState(() {
          locationText = 'Unable to determine address';
        });
      }
    } catch (e) {
      setState(() {
        locationText = 'Error: $e';
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

  final Map<String, List<String>> categoryMap = {
    'Traditional Sports Animal': [
      'Bull',
      'Camel',
      'Bird',
      'Pigeon',
      'Cock',
      'Dog',
      'Goat',
      'Horse',
      'Other',
    ],
    'Livestock Animal': [
      'Buffalo',
      'Sheep',
      'Goat',
      'Pigs',
      'Other',
    ],
    'Pet Animal': [
      'Dog',
      'Cat',
      'Bird',
      'Fishes',
      'Small Mammals',
      'Other',
    ],
    'Farm House Animal': ['Other'],
  };

  final List<String> genderOptions = ['Male', 'Female'];

  List<String> get types => categoryMap.keys.toList();

  List<String> get categories => categoryMap[selectedType] ?? [];

  // Validation function
  bool _validateFields() {
    final List<String> missingFields = [];

    if (selectedType == null) missingFields.add('Animal Type');
    if (selectedCategory == null) missingFields.add('Animal Category');
    if (nameController.text.trim().isEmpty) missingFields.add('Animal Name');
    if (ageController.text.trim().isEmpty) missingFields.add('Animal Age');
    if (selectedGender == null) missingFields.add('Animal Gender');
    if (priceController.text.trim().isEmpty) missingFields.add('Price');
    if (negotiableController.text.trim().isEmpty) missingFields.add('Negotiable');
    if (phoneController.text.trim().isEmpty) missingFields.add('Phone Number');
    if (descriptionController.text.trim().isEmpty) missingFields.add('Description');
    if (locationText == null || locationText!.isEmpty) missingFields.add('Location');
    if (imageOne == null) missingFields.add('First Image');

    if (missingFields.isNotEmpty) {
      _showSnackBar(
        'Missing Required Fields: ${missingFields.join(', ')}',
        Colors.red,
      );
      return false;
    }

    // Validate phone number
    if (phoneController.text.trim().length < 10) {
      _showSnackBar('Please enter a valid phone number', Colors.red);
      return false;
    }

    // Validate age
    final age = int.tryParse(ageController.text.trim());
    if (age == null || age <= 0) {
      _showSnackBar('Please enter a valid age', Colors.red);
      return false;
    }

    // Validate price
    final price = double.tryParse(priceController.text.trim());
    if (price == null || price <= 0) {
      _showSnackBar('Please enter a valid price', Colors.red);
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<GetProfileViewModel>(
        builder: (context, profileViewModel, child) {
          final walletBalance = profileViewModel.profile?.result?.first.walletBalance ?? 0;
          final username = profileViewModel.profile?.result?.first.username ?? 'User';
          final userId = profileViewModel.profile?.result?.first.id ?? 0;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildHeader(),

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
                                'Wallet Balance: ₹$walletBalance',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: walletBalance >= 15 ? Colors.green.shade700 : Colors.red.shade700,
                                ),
                              ),
                              Text(
                                walletBalance >= 15
                                    ? 'You can proceed with listing'
                                    : 'Minimum ₹15 required to list your animal',
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
                      buildLabel('Animal Types'),
                      buildSelectorBox(
                        selectedType,
                        'Select Animal Type',
                            () => showSelectionModal(
                          options: types,
                          title: 'Select Animal Type',
                          onSelected: (type) {
                            setState(() {
                              selectedType = type;
                              selectedCategory = null;
                            });
                          },
                        ),
                      ),

                      buildLabel('Animal Category'),
                      buildSelectorBox(
                        selectedCategory,
                        selectedType == null
                            ? 'Please select animal type first'
                            : 'Select Animal Category',
                        selectedType == null
                            ? () {}
                            : () => showSelectionModal(
                          options: categories,
                          title: 'Select Category',
                          onSelected: (cat) {
                            setState(() {
                              selectedCategory = cat;
                            });
                          },
                        ),
                      ),

                      buildLabel('Name of The Animal'),
                      buildTextField('Name of The Animal', nameController),

                      buildLabel('Enter Animal Age'),
                      buildTextField('Enter Animal Age', ageController, isNumeric: true),

                      buildLabel('Select Gender of Animal'),
                      buildSelectorBox(
                        selectedGender,
                        'Select Gender of Animal',
                            () => showSelectionModal(
                          options: genderOptions,
                          title: 'Select Gender',
                          onSelected: (gender) {
                            setState(() {
                              selectedGender = gender;
                            });
                          },
                        ),
                      ),

                      buildLabel('Price'),
                      buildTextField('Price', priceController, isNumeric: true),

                      buildLabel('Negotiable'),
                      buildSelectorBox(
                        negotiableController.text.isEmpty ? null : negotiableController.text,
                        'Is price negotiable?',
                            () => showSelectionModal(
                          options: ['Yes', 'No'],
                          title: 'Is Price Negotiable?',
                          onSelected: (value) {
                            setState(() {
                              negotiableController.text = value;
                            });
                          },
                        ),
                      ),

                      buildLabel('Your Phone Number'),
                      buildTextField('Enter your phone number', phoneController, isNumeric: true),

                      buildLabel('Animal Description'),
                      buildMultilineTextField('Enter Animal Description', descriptionController),

                      buildLabel('Get Address for Pashu'),
                      LocationSection(
                        getCurrentLocation: _getCurrentLocation,
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
                                  ? () => _handleSubmit(sellProvider, username ,userId)
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
                                    'Submitting...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                                  : Text(
                                walletBalance >= 15
                                    ? 'Submit & Pay ₹15'
                                    : 'Insufficient Balance',
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

  Future<void> _handleSubmit(SellPashuProvider sellProvider, String username, int userId) async {
    if (!_validateFields()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await sellProvider.postPashuData(
        image1: imageOne,
        image2: imageTwo,
        animalName: nameController.text.trim(),
        breed: selectedCategory ?? 'Other', // Use selected category as breed
        price: priceController.text.trim(),
        negotiable: negotiableController.text.trim(),
        animalType: selectedType ?? '',
        animalCategory: selectedCategory ?? '',
        username: username, // Dynamic username from profile
        age: ageController.text.trim(),
        gender: selectedGender ?? 'Unknown',
        description: descriptionController.text.trim(),
        phone: phoneController.text.trim(),
        referralCode: '',
        address: locationText ?? '',
        latitude: position!.latitude,
        longitude: position!.longitude,
        userId: userId.toString(),
      );

      if (sellProvider.errorMessage == null) {
        _showSnackBar('Pashu listed successfully!', Colors.green);

        // Refresh profile to update wallet balance
        Provider.of<GetProfileViewModel>(context, listen: false)
            .getProfile(widget.phoneNumber);

        // Clear form
        _clearForm();
      } else {
        _showSnackBar(sellProvider.errorMessage!, Colors.red);
      }
    } catch (e) {
      _showSnackBar('An error occurred: $e', Colors.red);
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

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: const Color(0xFF1E4A59), // Light green header color
      child: const Center(
        child: Text(
          'Sell Pashu',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Dark text
          ),
        ),
      ),
    );

  }}
