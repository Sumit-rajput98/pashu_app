import 'package:flutter/material.dart';
import 'package:pashu_app/model/pashu/all_pashu.dart';


import '../../AppManager/api/api_service/pashu_service/all_pashu_service.dart';

class AllPashuViewModel extends ChangeNotifier {
  final AllPashuService _allPashuService = AllPashuService();

  List<AllPashuModel> _pashuList = [];
  List<AllPashuModel> get pashuList => _pashuList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchAllPashu() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pashuList = await _allPashuService.getAllPashu();

      if (_pashuList.isEmpty) {
        _error = "No animals found";
      }
    } catch (e) {
      _error = "Failed to fetch data: ${e.toString()}";
      print("ViewModel Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
