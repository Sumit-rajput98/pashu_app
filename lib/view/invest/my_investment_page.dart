import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../AppManager/api/constant/api_constant.dart';
import '../../core/shared_pref_helper.dart';

class MyInvestmentPage extends StatefulWidget {
  const MyInvestmentPage({Key? key}) : super(key: key);

  @override
  State<MyInvestmentPage> createState() => _MyInvestmentPageState();
}

class _MyInvestmentPageState extends State<MyInvestmentPage> {
  List<dynamic> userInvestments = [];
  bool isLoading = true;
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    fetchMyInvestments();
  }

  Future<void> fetchMyInvestments() async {
    try {
      final number = await SharedPrefHelper.getPhoneNumber();

      if (number == null) {
        debugPrint('📛 Phone number not found.');
        return;
      }

      // Step 1: Get user profile by number
      final profileRes = await http.get(
        Uri.parse('${ApiConstant.baseUrl}api/getprofileByNumber/$number'),
      );

      if (profileRes.statusCode == 200) {
        final userData = jsonDecode(profileRes.body)['result'][0];
        currentUserId = userData['id'];
        debugPrint('👤 Logged in user ID: $currentUserId');
      } else {
        debugPrint('❌ Failed to fetch user profile');
        return;
      }

      // Step 2: Fetch investment records
      final investRes = await http.get(
        Uri.parse('${ApiConstant.baseUrl}api/investment_record'),
      );

      if (investRes.statusCode == 200) {
        final allInvestments = jsonDecode(investRes.body) as List;
        debugPrint('📦 Total investments: ${allInvestments.length}');

        // Step 3: Filter by user_id
        userInvestments = allInvestments
            .where((investment) => investment['user_id'] == currentUserId)
            .toList();

        debugPrint('✅ My investments: ${userInvestments.length}');
      } else {
        debugPrint('❌ Failed to fetch investment records');
      }
    } catch (e) {
      debugPrint('❌ Exception occurred: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildInvestmentCard(Map<String, dynamic> investment) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Investment ID: ${investment['investment_id']}", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text("Slots: ${investment['slots']}"),
            Text("Price: ₹${investment['price']}"),
            Text("Date: ${investment['investment_date']}"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Investment"),
        backgroundColor: const Color(0xFF1E4A59),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userInvestments.isEmpty
          ? const Center(child: Text("No investments found"))
          : ListView.builder(
        itemCount: userInvestments.length,
        itemBuilder: (context, index) {
          return buildInvestmentCard(userInvestments[index]);
        },
      ),
    );
  }
}