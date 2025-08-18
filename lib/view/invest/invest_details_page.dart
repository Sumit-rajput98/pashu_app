import 'package:flutter/material.dart';
import 'package:pashu_app/view/invest/widget/project_faq_widget.dart';
import 'package:pashu_app/view/invest/widget/project_lot_selector_widget.dart';
import 'package:pashu_app/view/invest/widget/project_overview_widget.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../model/invest/invest_model.dart';

class InvestDetailsPage extends StatefulWidget {
  final InvestModel project;
  final VoidCallback onBack;

  const InvestDetailsPage({
    super.key,
    required this.project,
    required this.onBack,
  });

  @override
  State<InvestDetailsPage> createState() => _InvestDetailsPageState();
}

class _InvestDetailsPageState extends State<InvestDetailsPage> {
  int selectedLots = 1;

  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void incrementLots() {
    if (selectedLots < widget.project.availableSlots) {
      setState(() {
        selectedLots++;
      });
    }
  }

  void decrementLots() {
    if (selectedLots > 1) {
      setState(() {
        selectedLots--;
      });
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final project = widget.project;
    final amount = selectedLots * 1;

    try {
      final verifyRes = await http.post(
        Uri.parse(
          'https://pashuparivar.com/api/payment/verify-investment-payment',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "userId": 1, // replace with actual userId
          "amount": amount,
          "slot": selectedLots,
          "razorpay_order_id": response.orderId,
          "razorpay_payment_id": response.paymentId,
          "razorpay_signature": response.signature,
        }),
      );

      final verifyJson = jsonDecode(verifyRes.body);

      if (verifyJson["success"] == true) {
        await http.post(
          Uri.parse("https://pashuparivar.com/api/investment_record"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "user_id": 1, // replace with actual userId
            "investment_id": project.id,
            "slots": selectedLots,
            "price": amount,
          }),
        );

        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.paymentCompletedSuccessfully,
        );
        // Navigate or update state as needed
      } else {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.paymentVerificationFailed,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context)!.errorVerifyingPayment,
      );
    }
  }

  void _initiatePayment() async {
    final amount = selectedLots * 1;

    try {
      final orderRes = await http.post(
        Uri.parse('https://pashuparivar.com/api/payment/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': amount}),
      );

      final orderJson = jsonDecode(orderRes.body);
      final orderId = orderJson['orderId'];

      var options = {
        'key': 'rzp_live_gm2iOnFy9nUmUx',
        'amount': amount * 100,
        'currency': 'INR',
        'name': 'Pashu Parivar',
        'description': 'Invest in ${widget.project.title}',
        'order_id': orderId,
        'image': 'https://pashuparivar.com/uploads/newlogo.png',
        'prefill': {
          'name': 'Demo User', // Replace with actual
          'contact': '9999999999',
          'email': 'demo@pashuparivar.com',
        },
        'theme': {'color': '#A5BE7E'},
      };

      _razorpay.open(options);
    } catch (e) {
      Fluttertoast.showToast(msg: "Could not initiate payment");
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "Payment failed: ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
      msg: "External Wallet Selected: ${response.walletName}",
    );
  }

  Future<void> openPdfInBrowser(String url) async {
    final uri = Uri.parse(url);
    try {
      final success = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!success) {
        debugPrint("Launch failed for $uri");
        // You can show a snackbar or alert here
      }
    } catch (e) {
      debugPrint("Exception while launching PDF: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                "https://pashuparivar.com/uploads/${project.projectImage}",
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // Description & Lots Selection
            ProjectLotSelectorWidget(
              project: widget.project,
              selectedLots: selectedLots,
              onIncrement: incrementLots,
              onDecrement: decrementLots,
              onProceed: _initiatePayment,
            ),

            // Project Overview
            ProjectOverviewWidget(project: widget.project),
            const SizedBox(height: 20),

            // Project Report
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.picture_as_pdf),
                      SizedBox(width: 8),
                      Text(
                        "Project Report",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "This document contains detailed information about the project, including planning, investment, breakdown, timelines and expectations.",
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final pdfUrl =
                            "https://pashuparivar.com/uploads/${project.projectReport}";
                        openPdfInBrowser(pdfUrl);
                      },

                      icon: const Icon(Icons.download),
                      label: const Text("Download Report"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ProjectFAQWidget(),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
