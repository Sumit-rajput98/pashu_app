import 'package:flutter/material.dart';
import 'package:pashu_app/view/invest/widget/my_investment_button.dart';

import 'live_projects_page.dart';

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleMyInvestmentTap() {
    // Navigate or handle action
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("My Investment button tapped")),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            Container(
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start, // ✅ Align tabs from start (no extra margin)
                labelColor: Color(0xFF1E4A59),
                unselectedLabelColor: Color(0xFF1E4A59),
                indicatorColor: const Color(0xFF35C75A),
                indicatorWeight: 3,
                padding: EdgeInsets.zero, // ✅ Remove extra padding on sides
                tabs: const [
                  Tab(text: 'Upcoming Projects',),
                  Tab(text: 'Live Projects'),
                  Tab(text: 'Completed Projects'),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  const Center(child: Text('Upcoming Projects')),
                  LiveProjectsPage(),
                  Center(child: Text('Completed Projects')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
