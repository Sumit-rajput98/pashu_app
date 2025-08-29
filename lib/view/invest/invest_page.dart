import 'package:flutter/material.dart';
import 'package:pashu_app/view/invest/projects_list_page.dart';
import 'package:provider/provider.dart';
import 'package:pashu_app/view/invest/widget/my_investment_button.dart';
import '../../core/navigation_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/shared_pref_helper.dart';
import '../../login_dialog.dart';
import '../../view_model/pashuVM/get_invest_view_model.dart';

class InvestPage extends StatefulWidget {
  const InvestPage({super.key});

  @override
  State<InvestPage> createState() => _InvestPageState();
}

class _InvestPageState extends State<InvestPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoggedIn =false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this,initialIndex: 1);
    Future.microtask(() {
      Provider.of<GetInvestViewModel>(context, listen: false).loadInvestments();
    });
    getLoginStatus();
  }
  void getLoginStatus()async{
    isLoggedIn = await SharedPrefHelper.isLoggedIn();
    setState(() {

    });
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleMyInvestmentTap() {
    isLoggedIn ?
    Provider.of<NavigationController>(context, listen: false).openMyInvestment() :
        showLoginRequiredDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = Provider.of<GetInvestViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      l10n.investmentProject,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E4A59),
                          fontSize: 18
                      )
                  ),
                  MyInvestmentButton(onPressed: _handleMyInvestmentTap),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: const Color(0xFF1E4A59),
              unselectedLabelColor: const Color(0xFF1E4A59),
              indicatorColor: const Color(0xFF35C75A),
              indicatorWeight: 3,
              padding: EdgeInsets.zero,
              tabs: [
                Tab(text: l10n.upcomingProjects),
                Tab(text: l10n.liveProjects),
                Tab(text: l10n.completedProjects),
              ],
            ),
            Expanded(
              child: viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                controller: _tabController,
                children: [
                  ProjectsListPage(projects: viewModel.upcomingProjects),
                  ProjectsListPage(projects: viewModel.liveProjects),
                  ProjectsListPage(projects: viewModel.completedProjects),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
