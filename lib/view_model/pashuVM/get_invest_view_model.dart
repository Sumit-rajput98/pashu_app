import 'package:flutter/material.dart';
import '../../AppManager/api/api_service/pashu_service/get_invest_service.dart';
import '../../model/invest/invest_model.dart';


class GetInvestViewModel extends ChangeNotifier {
  final List<InvestModel> _upcomingProjects = [];
  final List<InvestModel> _liveProjects = [];
  final List<InvestModel> _completedProjects = [];

  List<InvestModel> get upcomingProjects => _upcomingProjects;
  List<InvestModel> get liveProjects => _liveProjects;
  List<InvestModel> get completedProjects => _completedProjects;

  bool isLoading = false;
  String? error;

  Future<void> loadInvestments() async {
    isLoading = true;
    notifyListeners();

    try {
      final projects = await GetInvestService().fetchInvestmentProjects();
      _upcomingProjects.clear();
      _liveProjects.clear();
      _completedProjects.clear();

      for (var project in projects) {
        switch (project.status.toLowerCase()) {
          case 'upcoming':
            _upcomingProjects.add(project);
            break;
          case 'active':
            _liveProjects.add(project);
            break;
          case 'matured':
            _completedProjects.add(project);
            break;
        }
      }
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}