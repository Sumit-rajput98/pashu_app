import 'package:flutter/material.dart';
import '../../AppManager/api/api_service/pashu_service/get_categories_service.dart';
import '../../model/pashu/category_model.dart';

class GetCategoryViewModel extends ChangeNotifier {
  final GetCategoriesService _allPashuService = GetCategoriesService();

  List<CategoryModel> _categoryList = [];
  List<CategoryModel> get categoryList => _categoryList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchAllCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categoryList = await _allPashuService.getAllCategories();

      if (_categoryList.isEmpty) {
        _error = "No Categories found";
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
