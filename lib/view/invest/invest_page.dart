import 'package:flutter/material.dart';
import 'package:pashu_app/view/invest/projects_list_page.dart';
import 'package:provider/provider.dart';
import 'package:pashu_app/view/invest/widget/my_investment_button.dart';

import '../../view_model/pashuVM/get_invest_view_model.dart';

class InvestPage extends StatefulWidget {
  const InvestPage({super.key});

  @override
  State<InvestPage> createState() => _InvestPageState();
}

class _InvestPageState extends State<InvestPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      Provider.of<GetInvestViewModel>(context, listen: false).loadInvestments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleMyInvestmentTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("My Investment button tapped")),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  const Text('Investment Project', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E4A59), fontSize: 18)),
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
              tabs: const [
                Tab(text: 'Upcoming Projects'),
                Tab(text: 'Live Projects'),
                Tab(text: 'Completed Projects'),
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
