import 'package:flutter/material.dart';
import 'package:pashu_app/model/pashu/all_pashu.dart';
import '../../AppManager/api/api_service/pashu_service/get_wishlist_service.dart';

class WishlistViewModel extends ChangeNotifier {
  final GetWishlistService _service = GetWishlistService();

  List<AllPashuModel> _wishlist = [];
  List<AllPashuModel> get wishlist => _wishlist;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchWishlist() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _wishlist = await _service.getWishlist();
      if (_wishlist.isEmpty) {
        _error = "No wishlist animals found";
      }
    } catch (e) {
      _error = "Failed to fetch wishlist: " + e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeFromWishlist({
    required String name,
    required String phoneNumber,
    required int id,
  }) async {
    final result = await _service.removeFromWishlist(
      name: name,
      phoneNumber: phoneNumber,
      id: id,
    );
    if (result) {
      _wishlist.removeWhere((item) => item.id == id);
      notifyListeners();
    }
    return result;
  }
}
