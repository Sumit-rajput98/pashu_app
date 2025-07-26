import 'package:flutter/material.dart';
import 'package:pashu_app/AppManager/api/api_service/auth_service/get_counter_service.dart';



import '../../model/auth/counter_model.dart';

class GetCounterViewModel extends ChangeNotifier{
  final GetCounterService _service = GetCounterService();

  CounterModel? _counter;
  CounterModel? get counter => _counter;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> getCounter(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
     _counter = await _service.getCounter(userId);
      if(counter!.result!.isEmpty){
        _error = "Not Enough Spent";
      }
    } catch (e) {
      _error = "Failed $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}