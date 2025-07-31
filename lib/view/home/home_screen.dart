import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:pashu_app/core/shared_pref_helper.dart';
import 'package:pashu_app/model/auth/profile_model.dart';
import 'package:pashu_app/view/auth/profile_page.dart';
import 'package:pashu_app/view/home/pashu_insurance_form.dart';
import 'package:pashu_app/view_model/AuthVM/get_profile_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_colors.dart';
import '../../core/app_logo.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/navigation_controller.dart';

import 'animal_loan_page.dart';
import 'live_race_page.dart';

class HomeScreen extends StatefulWidget {
  final String phoneNumber;
  const HomeScreen({super.key, required this.phoneNumber});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Location variables
  int totalSlots = 10000;
  int usedSlots = 0;
  int remainingSlots = 0;
  int buyLength =0;

  String _currentLocation = 'Fetching location...';
  Position? _currentPosition;
  bool _locationPermissionGranted = false;
  bool _locationLoading = false;
  bool _locationError = false;

  // Slider controllers for statistics
  final PageController _animalSliderController = PageController();
  final PageController _buyerSliderController = PageController();
  int _currentAnimalIndex = 0;
  int _currentBuyerIndex = 0;
  Timer? _animalSliderTimer;
  Timer? _buyerSliderTimer;

  // Blinking animation controller
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  // Sample data for sliders
  final List<Map<String, dynamic>> _newAnimals = [
    {'count': '31', 'type': 'Cows', 'image': 'assets/image6.jpg'},
    {'count': '15', 'type': 'Buffalo', 'image': 'assets/image7.webp'},
    {'count': '23', 'type': 'Goats', 'image': 'assets/image3.jpg'},
    {'count': '18', 'type': 'Sheep', 'image': 'assets/image5.jpg'},
  ];

  final List<Map<String, dynamic>> _newBuyers = [
    {
      'count': '971',
      'category': 'Farmers',
      'trend': '+12%',
      'image': 'assets/image3.jpg',
    },
    {
      'count': '543',
      'category': 'Dealers',
      'trend': '+8%',
      'image': 'assets/image5.jpg',
    },
    {
      'count': '234',
      'category': 'Investors',
      'trend': '+15%',
      'image': 'assets/image6.jpg',
    },
    {
      'count': '167',
      'category': 'Breeders',
      'trend': '+6%',
      'image': 'assets/image7.webp',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeBlinkAnimation();
    _startAnimalSlider();
    _startBuyerSlider();
    fetchSlotData();
    _checkLocationPermissionOnInit();
  }

  Future<void> _checkLocationPermissionOnInit() async {
    // Check if location is already saved
    final prefs = await SharedPreferences.getInstance();
    final savedLat = prefs.getDouble('latitude');
    final savedLng = prefs.getDouble('longitude');

    if (savedLat != null && savedLng != null) {
      // Location already saved, get address from coordinates
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(savedLat, savedLng);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          setState(() {
            _currentLocation = '${place.locality}, ${place.administrativeArea}, ${place.country}';
            _locationPermissionGranted = true;
          });
        }
      } catch (e) {
        print('Error getting location from saved coordinates: $e');
        setState(() {
          _currentLocation = 'Location saved';
          _locationPermissionGranted = true;
        });
      }
    } else {
      // No saved location, check permissions
      await _checkLocationPermission();
    }
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationPermissionGranted = false;
        _locationError = true;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      setState(() {
        _locationPermissionGranted = false;
      });
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationPermissionGranted = false;
        _locationError = true;
      });
      return;
    }

    // Permissions are granted, get current location
    setState(() {
      _locationPermissionGranted = true;
    });
    await _getCurrentLocation();
  }

  Future<void> _requestLocationPermission() async {
    setState(() {
      _locationLoading = true;
      _locationError = false;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled
        await Geolocator.openLocationSettings();
        setState(() {
          _locationLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationLoading = false;
            _locationError = true;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever
        await Geolocator.openAppSettings();
        setState(() {
          _locationLoading = false;
          _locationError = true;
        });
        return;
      }

      // Permissions granted, get location
      await _getCurrentLocation();
      setState(() {
        _locationPermissionGranted = true;
      });
    } catch (e) {
      print('Error requesting location permission: $e');
      setState(() {
        _locationLoading = false;
        _locationError = true;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _locationLoading = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentPosition = position;
      });

      // Save location to SharedPreferences
      SharedPrefHelper.saveLocation(position.latitude, position.longitude);

      // Get address from coordinates
      await _getAddressFromCoordinates(position.latitude, position.longitude);

      setState(() {
        _locationLoading = false;
      });
    } catch (e) {
      print('Error getting current location: $e');
      setState(() {
        _currentLocation = 'Location not available';
        _locationLoading = false;
        _locationError = true;
      });
    }
  }

  Future<void> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _currentLocation = '${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}';
        });
      }
    } catch (e) {
      print('Error getting address: $e');
      setState(() {
        _currentLocation = 'Lat: ${latitude.toStringAsFixed(4)}, Lng: ${longitude.toStringAsFixed(4)}';
      });
    }
  }

  // Future<void> fetchSlotData() async {
  //   try {
  //     final buyRes = await http.get(Uri.parse('https://pashuparivar.com/api/allpashu'));
  //     final sellRes = await http.get(Uri.parse('https://pashuparivar.com/api/getprofile'));
  //
  //     if (buyRes.statusCode == 200 && sellRes.statusCode == 200) {
  //       final buyData = jsonDecode(buyRes.body);
  //       final sellData = jsonDecode(sellRes.body);
  //       final filteredBuy = buyData.where((item) => (item.status == "Active" || item.status == "Sold" || item.status == "verified pashu")).toList();
  //       final filteredSell = sellData.where((item) => item['referralcode'] != null).toList();
  //
  //       setState(() {
  //         usedSlots = filteredSell.length;
  //         remainingSlots = totalSlots - usedSlots;
  //         buyLength = filteredBuy.length;
  //         sellLength = sellData.data.length;
  //       });
  //     }
  //   } catch (e) {
  //     print('Error fetching slot data: $e');
  //   }
  // }

  Future<void> fetchSlotData() async {
    try {
      final sellRes = await http.get(Uri.parse('https://pashuparivar.com/api/getprofile'));
      final buyRes = await http.get(Uri.parse('https://pashuparivar.com/api/allpashu'));


      if (sellRes.statusCode == 200) {
        final sellData = jsonDecode(sellRes.body);
        final buyData = jsonDecode(buyRes.body);
        final filteredSell = sellData.where((item) => item['referralcode'] != null).toList();
        final filteredBuy = buyData.where((item) => (item['status'] == "Active" || item['status'] == "Sold" || item['status'] == "verified pashu")).toList();

        setState(() {
          usedSlots = filteredSell.length;
          remainingSlots = totalSlots - usedSlots;
          buyLength = filteredBuy.length;
        });
      }
    } catch (e) {
      print('Error fetching slot data: $e');
    }
  }

  void _initializeBlinkAnimation() {
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _blinkAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    _blinkController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _blinkController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _blinkController.forward();
      }
    });

    _blinkController.forward();
  }

  void _startAnimalSlider() {
    _animalSliderTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentAnimalIndex < _newAnimals.length - 1) {
        _currentAnimalIndex++;
      } else {
        _currentAnimalIndex = 0;
      }

      if (_animalSliderController.hasClients) {
        _animalSliderController.animateToPage(
          _currentAnimalIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _startBuyerSlider() {
    _buyerSliderTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentBuyerIndex < _newBuyers.length - 1) {
        _currentBuyerIndex++;
      } else {
        _currentBuyerIndex = 0;
      }

      if (_buyerSliderController.hasClients) {
        _buyerSliderController.animateToPage(
          _currentBuyerIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _animalSliderTimer?.cancel();
    _buyerSliderTimer?.cancel();
    _animalSliderController.dispose();
    _buyerSliderController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: !_locationPermissionGranted
            ? _buildLocationPermissionScreen()
            : _buildMainContent(screenWidth),
      ),
    );
  }

  Widget _buildLocationPermissionScreen() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Location Icon
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.lightSage.withOpacity(0.15),
                  AppColors.lightSage.withOpacity(0.08),
                ],
              ),
              border: Border.all(color: AppColors.primaryDark, width: 2),
            ),
            child: Icon(
              _locationError ? Icons.location_off_rounded : Icons.location_on_rounded,
              size: 80,
              color: _locationError ? Colors.red : AppColors.primaryDark,
            ),
          ),

          const SizedBox(height: 40),

          // Title
          Text(
            _locationError
                ? "Location Access Required"
                : AppLocalizations.of(context)!.allowLocationAccess,
            style: AppTextStyles.heading.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            _locationError
                ? 'Please enable location services in your device settings to continue.'
                : AppLocalizations.of(context)!.locationDescription,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryDark.withOpacity(0.7),
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Allow Location Button
          Container(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _locationLoading ? null : _requestLocationPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: AppColors.primaryDark.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _locationLoading
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
                    'Getting Location...',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _locationError ? Icons.settings_rounded : Icons.location_on_outlined,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _locationError
                        ? 'Open Settings'
                        : AppLocalizations.of(context)!.allowLocationAccess,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Retry Button (shown when there's an error)
          if (_locationError && !_locationLoading)
            Container(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: _requestLocationPermission,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryDark,
                  side: BorderSide(color: AppColors.primaryDark),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh_rounded, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Try Again',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Privacy Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.privacy_tip_outlined,
                  color: Colors.blue,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.locationPrivacyNote,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.blue,
                      fontSize: 12,
                      height: 1.3,
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
  Widget _buildMainContent(double screenWidth) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // First 10,000 Users Section
          _buildFirst10KUsersSection(screenWidth),

          // Investment Card
          _buildInvestmentCard(screenWidth),

          // All Service Cards Section
          _buildAllServiceCards(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: AppColors.lightSage,
      child: Center(
        child: Text(
          "Hi Ankit,Welcome To Pashu Parivar",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    final localizations = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // App Logo
          AppLogo(size: 50),

          const SizedBox(width: 16),

          // App Name and Location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.welcome,
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.lightSage,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: AppColors.lightSage.withOpacity(0.8),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _currentLocation,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.lightSage.withOpacity(0.8),
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Notification/Profile Icon
          GestureDetector(
            onTap: () async {
              String? phoneNumber = await SharedPrefHelper.getPhoneNumber();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ProfilePage(phoneNumber: phoneNumber ?? ''),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
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
          ),
        ],
      ),
    );
  }

  Widget _buildFirst10KUsersSection(double screenWidth) {

    final localizations = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightSage.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryDark, width: 2),
      ),
      child: Row(
        children: [
          // Gift Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.card_giftcard_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${localizations.firstUsers} ₹25 ${localizations.referralBonusOnly}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 8),

                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryDark.withOpacity(0.8),
                    ),
                    children: [
                      TextSpan(text: localizations.slotsLeft(remainingSlots)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentCard(double screenWidth) {
    final localizations = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.lightSage, AppColors.lightSage.withOpacity(0.9)],
        ),
        border: Border.all(color: AppColors.primaryDark, width: 2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightSage.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background Pattern
            Positioned.fill(child: CustomPaint(painter: PatternPainter())),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  // Left Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // NEW Badge
                        AnimatedBuilder(
                          animation: _blinkAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _blinkAnimation.value,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'NEW',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        Text(
                          localizations.invest,
                          style: AppTextStyles.heading.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          localizations.growWealth,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primaryDark.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 16),

                        GestureDetector(
                          onTap: () {
                            Provider.of<NavigationController>(
                              context,
                              listen: false,
                            ).changeTab(4);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              localizations.startInvesting,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.lightSage,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right Image/Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.trending_up_rounded,
                      color: AppColors.primaryDark,
                      size: 40,
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

  Widget _buildAllServiceCards() {
    return Column(
      children: [
        // Live Races Card

        // New Animal Card with Slider - Updated Layout
        _buildAnimalSliderCard(),

        const SizedBox(height: 16),

        // New Buyers Card with Slider - Updated Layout
        _buildBuyerSliderCard(),

        const SizedBox(height: 16),

        // Animal Insurance Card
        _buildServiceCard(
          image: 'assets/Inlo2.png',
          title: AppLocalizations.of(context)!.animalInsurance,
          subtitle: AppLocalizations.of(context)!.appTitle,
          buttonLabel: AppLocalizations.of(context)!.applyNow,
          badge: AppLocalizations.of(context)!.newBadge,
          primaryColor: const Color(0xFF4CAF50),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PashuInsuranceFormPage(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        _buildServiceCard(
          image: 'assets/cowrace.jpg',
          title: AppLocalizations.of(context)!.liveRaces,
          buttonLabel: AppLocalizations.of(context)!.viewLive,
          primaryColor: AppColors.lightSage,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LiveRacePage()),
            );
          },
        ),

        const SizedBox(height: 16),

        // Animal Loan Card
        _buildServiceCard(
          image: 'assets/loan.png',
          title: AppLocalizations.of(context)!.pashuLoan,
          subtitle: AppLocalizations.of(context)!.appTitle,
          buttonLabel: AppLocalizations.of(context)!.applyNow,
          badge: AppLocalizations.of(context)!.newBadge,
          primaryColor: const Color(0xFF2196F3),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PashuLoanFormPage(),
              ),
            );
          },
        ),
      ],
    );
  }
  Widget _buildServiceCard({
    required String image,
    required String title,
    String? subtitle,
    required String buttonLabel,
    String? badge,
    required Color primaryColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Left Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 120,
                    height: 120, // Increased height
                    child: Image.asset(
                      image,
                      fit: BoxFit.contain, // Show entire image
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            title.contains('Races')
                                ? Icons.sports_motorsports_rounded
                                : title.contains('Insurance')
                                ? Icons.security_rounded
                                : title.contains('Loan')
                                ? Icons.account_balance_rounded
                                : Icons.pets_rounded,
                            color: primaryColor,
                            size: 50,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Badge positioning
                if (badge != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: AnimatedBuilder(
                      animation: _blinkAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _blinkAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badge,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 16),

            // Right Content Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (subtitle != null) ...[
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryDark.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],

                  Text(
                    title,
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: AppColors.lightSage,
                        elevation: 4,
                        shadowColor: AppColors.primaryDark.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        buttonLabel,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.lightSage,
                        ),
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

  // Updated Animal Slider Card matching the image layout
  Widget _buildAnimalSliderCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightSage.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background sliding images
            PageView.builder(
              controller: _animalSliderController,
              onPageChanged: (index) {
                setState(() {
                  _currentAnimalIndex = index;
                });
              },
              itemCount: _newAnimals.length,
              itemBuilder: (context, index) {
                final item = _newAnimals[index];
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(item['image']),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.3),
                        BlendMode.darken,
                      ),
                      onError: (exception, stackTrace) {
                        // Handle image loading error
                      },
                    ),
                  ),
                );
              },
            ),

            // Fallback for missing images
            if (_newAnimals[_currentAnimalIndex]['image'] == null)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryDark.withOpacity(0.8),
                      AppColors.primaryDark.withOpacity(0.6),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.pets_rounded,
                    size: 60,
                    color: AppColors.lightSage,
                  ),
                ),
              ),

            // Content overlay
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Left side content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _currentLocation.split(',')[0],
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Count
                        Text(
                          "$buyLength",
                          style: AppTextStyles.heading.copyWith(
                            color: Colors.red,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(
                                offset: const Offset(1, 1),
                                blurRadius: 3,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),

                        // Label
                        Text(
                          AppLocalizations.of(context)!.newAnimal,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right side content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Animal type
                      const Spacer(),

                      // Buy button
                      GestureDetector(
                        onTap: () {
                          Provider.of<NavigationController>(
                            context,
                            listen: false,
                          ).changeTab(0);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.buyAnimal,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.lightSage,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Page indicators
            Positioned(
              bottom: 8,
              left: 20,
              child: Row(
                children: List.generate(
                  _newAnimals.length,
                  (index) => Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _currentAnimalIndex == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Updated Buyer Slider Card matching the image layout
  Widget _buildBuyerSliderCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightSage.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background sliding images for buyers
            PageView.builder(
              controller: _buyerSliderController,
              onPageChanged: (index) {
                setState(() {
                  _currentBuyerIndex = index;
                });
              },
              itemCount: _newBuyers.length,
              itemBuilder: (context, index) {
                final item = _newBuyers[index];
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        item['image'] ?? 'assets/default_buyer.jpg',
                      ),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.3),
                        BlendMode.darken,
                      ),
                      onError: (exception, stackTrace) {
                        // Handle image loading error
                      },
                    ),
                  ),
                );
              },
            ),

            // Fallback for missing images
            if (_newBuyers[_currentBuyerIndex]['image'] == null)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryDark.withOpacity(0.8),
                      AppColors.primaryDark.withOpacity(0.6),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.people_rounded,
                    size: 60,
                    color: AppColors.lightSage,
                  ),
                ),
              ),

            // Content overlay
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Left side content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _currentLocation.split(',')[0],
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Count
                        Text(
                          "971",
                          style: AppTextStyles.heading.copyWith(
                            color: Colors.red,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(
                                offset: const Offset(1, 1),
                                blurRadius: 3,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),

                        // Label
                        Text(
                          AppLocalizations.of(context)!.newBuyers,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right side content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Buyer category indicator (optional)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.trending_up_rounded,
                              color: Colors.green,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+12%',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Sell Animal button
                      GestureDetector(
                        onTap: () {
                          Provider.of<NavigationController>(
                            context,
                            listen: false,
                          ).changeTab(1);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.sellAnimal,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.lightSage,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Page indicators
            Positioned(
              bottom: 8,
              left: 20,
              child: Row(
                children: List.generate(
                  _newBuyers.length,
                  (index) => Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _currentBuyerIndex == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Pattern Painter for Investment Card Background
class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.primaryDark.withOpacity(0.05)
          ..strokeWidth = 1;

    // Draw subtle pattern lines
    for (int i = 0; i < size.width; i += 20) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i + 10, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
