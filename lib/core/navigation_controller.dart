import 'package:flutter/material.dart';
import '../model/auth/profile_model.dart';
import '../model/invest/invest_model.dart';
import '../model/pashu/all_pashu.dart';
import '../model/pashu/category_model.dart';

class NavigationController extends ChangeNotifier {
  int _selectedIndex = 2;

  // View state flags
  bool _isProfileOpen = false;
  bool _isMyInvestmentOpen = false;
  bool _isProjectsListOpen = false;
  bool _isInvestDetailsOpen = false;
  bool _isAnimalDetailOpen = false;
  bool _isSubscriptionOpen = false;
  bool _isVerifiedPashuOpen = false;
  bool _isTransactionOpen = false;
  bool _isEditProfileOpen = false;
  bool _isListedPashuOpen = false;
  bool _isSoldOutHistoryOpen = false;
  bool _isReferralOpen = false;
  bool _isTermsPrivacyOpen = false;
  bool _isContactUsOpen = false;
  bool _isWithdrawOpen = false;
  bool _isRaceDetailOpen = false;

  // NEW flags
  bool _isPashuInsuranceOpen = false;
  bool _isLiveRaceOpen = false;
  bool _isPashuLoanOpen = false;

  // Data for views
  List<InvestModel> _projectsList = [];
  InvestModel? _selectedInvestProject;
  AllPashuModel? _selectedAnimal;
  CategoryModel? _selectedRaceCategory;
  double? _selectedDistance;

  String? _subscriptionPhone;
  String? _referralCode;
  String? _referralUsername;
  String? _withdrawPhone;
  String? _withdrawUserId;

  Result? _userProfileForEdit;

  // Getters
  int get selectedIndex => _selectedIndex;

  int get stackIndex {
    if (_isProfileOpen) return 5;
    if (_isMyInvestmentOpen) return 6;
    if (_isAnimalDetailOpen) return 7;
    if (_isSubscriptionOpen) return 8;
    if (_isVerifiedPashuOpen) return 9;
    if (_isTransactionOpen) return 10;
    if (_isEditProfileOpen) return 11;
    if (_isListedPashuOpen) return 12;
    if (_isSoldOutHistoryOpen) return 13;
    if (_isReferralOpen) return 14;
    if (_isTermsPrivacyOpen) return 15;
    if (_isContactUsOpen) return 16;
    if (_isWithdrawOpen) return 17;
    if (_isProjectsListOpen) return 18;
    if (_isInvestDetailsOpen) return 19;
    if (_isPashuInsuranceOpen) return 20;
    if (_isLiveRaceOpen) return 21;
    if (_isPashuLoanOpen) return 22;
    if (_isRaceDetailOpen) return 23;
    return _selectedIndex;
  }

  // View flags
  bool get isProfileOpen => _isProfileOpen;
  bool get isMyInvestmentOpen => _isMyInvestmentOpen;
  bool get isProjectsListOpen => _isProjectsListOpen;
  bool get isInvestDetailsOpen => _isInvestDetailsOpen;
  bool get isAnimalDetailOpen => _isAnimalDetailOpen;
  bool get isSubscriptionOpen => _isSubscriptionOpen;
  bool get isVerifiedPashuOpen => _isVerifiedPashuOpen;
  bool get isTransactionOpen => _isTransactionOpen;
  bool get isEditProfileOpen => _isEditProfileOpen;
  bool get isListedPashuOpen => _isListedPashuOpen;
  bool get isSoldOutHistoryOpen => _isSoldOutHistoryOpen;
  bool get isReferralOpen => _isReferralOpen;
  bool get isTermsPrivacyOpen => _isTermsPrivacyOpen;
  bool get isContactUsOpen => _isContactUsOpen;
  bool get isWithdrawOpen => _isWithdrawOpen;
  bool get isRaceDetailOpen => _isRaceDetailOpen;

  // NEW flags getters
  bool get isPashuInsuranceOpen => _isPashuInsuranceOpen;
  bool get isLiveRaceOpen => _isLiveRaceOpen;
  bool get isPashuLoanOpen => _isPashuLoanOpen;

  // Data getters
  List<InvestModel> get projectsList => _projectsList;
  InvestModel? get selectedInvestProject => _selectedInvestProject;
  AllPashuModel? get selectedAnimal => _selectedAnimal;
  double? get selectedDistance => _selectedDistance;
  String? get subscriptionPhone => _subscriptionPhone;
  String? get referralCode => _referralCode;
  String? get referralUsername => _referralUsername;
  String? get withdrawPhone => _withdrawPhone;
  String? get withdrawUserId => _withdrawUserId;
  Result? get userProfileForEdit => _userProfileForEdit;
  CategoryModel? get selectedRaceCategory => _selectedRaceCategory;

  // Tab navigation
  void changeTab(int index) {
    _selectedIndex = index;
    _resetAllFlags();
    notifyListeners();
  }

  void goToBuy() => changeTab(0);
  void goToSell() => changeTab(1);
  void goToHome() => changeTab(2);
  void goToWishlist() => changeTab(3);
  void goToInvest() => changeTab(4);

  // Navigation actions
  void openProfile() {
    _resetAllFlags();
    _isProfileOpen = true;
    notifyListeners();
  }

  void closeProfile() {
    _isProfileOpen = false;
    notifyListeners();
  }

  void openMyInvestment() {
    _resetAllFlags();
    _isMyInvestmentOpen = true;
    notifyListeners();
  }

  void closeMyInvestment() {
    _isMyInvestmentOpen = false;
    notifyListeners();
  }

  void openProjectsList(List<InvestModel> projects) {
    _resetAllFlags();
    _isProjectsListOpen = true;
    _projectsList = projects;
    notifyListeners();
  }

  void closeProjectsList() {
    _isProjectsListOpen = false;
    _projectsList = [];
    notifyListeners();
  }

  void openInvestDetails(InvestModel project) {
    _resetAllFlags();
    _isInvestDetailsOpen = true;
    _selectedInvestProject = project;
    notifyListeners();
  }

  void closeInvestDetails() {
    _isInvestDetailsOpen = false;
    _selectedInvestProject = null;
    notifyListeners();
  }

  void openAnimalDetail(AllPashuModel animal, double distance) {
    _resetAllFlags();
    _selectedAnimal = animal;
    _selectedDistance = distance;
    _isAnimalDetailOpen = true;
    notifyListeners();
  }

  void closeAnimalDetail() {
    _isAnimalDetailOpen = false;
    _selectedAnimal = null;
    _selectedDistance = null;
    notifyListeners();
  }

  void openSubscription(String phone) {
    _resetAllFlags();
    _isSubscriptionOpen = true;
    _subscriptionPhone = phone;
    notifyListeners();
  }

  void closeSubscription() {
    _isSubscriptionOpen = false;
    _subscriptionPhone = null;
    notifyListeners();
  }

  void openVerifiedPashu() {
    _resetAllFlags();
    _isVerifiedPashuOpen = true;
    notifyListeners();
  }

  void closeVerifiedPashu() {
    _isVerifiedPashuOpen = false;
    notifyListeners();
  }

  void openTransaction() {
    _resetAllFlags();
    _isTransactionOpen = true;
    notifyListeners();
  }

  void closeTransaction() {
    _isTransactionOpen = false;
    notifyListeners();
  }

  void openEditProfile(Result userProfile) {
    _resetAllFlags();
    _userProfileForEdit = userProfile;
    _isEditProfileOpen = true;
    notifyListeners();
  }

  void closeEditProfile() {
    _isEditProfileOpen = false;
    _userProfileForEdit = null;
    notifyListeners();
  }

  void openListedPashu() {
    _resetAllFlags();
    _isListedPashuOpen = true;
    notifyListeners();
  }

  void closeListedPashu() {
    _isListedPashuOpen = false;
    notifyListeners();
  }

  void openSoldOutHistory() {
    _resetAllFlags();
    _isSoldOutHistoryOpen = true;
    notifyListeners();
  }

  void closeSoldOutHistory() {
    _isSoldOutHistoryOpen = false;
    notifyListeners();
  }

  void openReferral(String code, String username) {
    _resetAllFlags();
    _referralCode = code;
    _referralUsername = username;
    _isReferralOpen = true;
    notifyListeners();
  }

  void closeReferral() {
    _isReferralOpen = false;
    _referralCode = null;
    _referralUsername = null;
    notifyListeners();
  }

  void openTermsPrivacy() {
    _resetAllFlags();
    _isTermsPrivacyOpen = true;
    notifyListeners();
  }

  void closeTermsPrivacy() {
    _isTermsPrivacyOpen = false;
    notifyListeners();
  }

  void openContactUs() {
    _resetAllFlags();
    _isContactUsOpen = true;
    notifyListeners();
  }

  void closeContactUs() {
    _isContactUsOpen = false;
    notifyListeners();
  }

  void openWithdraw(String phone, String userId) {
    _resetAllFlags();
    _isWithdrawOpen = true;
    _withdrawPhone = phone;
    _withdrawUserId = userId;
    notifyListeners();
  }

  void closeWithdraw() {
    _isWithdrawOpen = false;
    _withdrawPhone = null;
    _withdrawUserId = null;
    notifyListeners();
  }

  // 🚨 NEW Page Handlers

  void openPashuInsurance() {
    _resetAllFlags();
    _isPashuInsuranceOpen = true;
    notifyListeners();
  }

  void closePashuInsurance() {
    _isPashuInsuranceOpen = false;
    notifyListeners();
  }

  void openLiveRace() {
    _resetAllFlags();
    _isLiveRaceOpen = true;
    notifyListeners();
  }

  void closeLiveRace() {
    _isLiveRaceOpen = false;
    notifyListeners();
  }

  void openPashuLoan() {
    _resetAllFlags();
    _isPashuLoanOpen = true;
    notifyListeners();
  }

  void closePashuLoan() {
    _isPashuLoanOpen = false;
    notifyListeners();
  }

  void openRaceDetail(CategoryModel category) {
    _resetAllFlags();
    _isRaceDetailOpen = true;
    _selectedRaceCategory = category;
    notifyListeners();
  }

  void closeRaceDetail() {
    _isRaceDetailOpen = false;
    _selectedRaceCategory = null;
    notifyListeners();
  }

  // Reset all flags
  void _resetAllFlags() {
    _isProfileOpen = false;
    _isMyInvestmentOpen = false;
    _isProjectsListOpen = false;
    _isInvestDetailsOpen = false;
    _isAnimalDetailOpen = false;
    _isSubscriptionOpen = false;
    _isVerifiedPashuOpen = false;
    _isTransactionOpen = false;
    _isEditProfileOpen = false;
    _isListedPashuOpen = false;
    _isSoldOutHistoryOpen = false;
    _isReferralOpen = false;
    _isTermsPrivacyOpen = false;
    _isContactUsOpen = false;
    _isWithdrawOpen = false;
    _isRaceDetailOpen = false;

    _isPashuInsuranceOpen = false;
    _isLiveRaceOpen = false;
    _isPashuLoanOpen = false;
  }
}
