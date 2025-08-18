import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pashu_app/core/shared_pref_helper.dart';

import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/app_colors.dart';
import '../../core/app_logo.dart';

class Transaction {
  final String amount;
  final String createdAt;
  final String razorpayPaymentId;
  final String type;
  final String status;
  final String comment;


  Transaction({
    required this.amount,
    required this.createdAt,
    required this.razorpayPaymentId,
    required this.type,
    required this.status,
    required this.comment,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      amount: json['amount'].toString(),
      createdAt: json['created_at'],
      razorpayPaymentId: json['razorpay_payment_id'] ?? '',
      type: json['type'],
      status: json['status'],
      comment: json['comment'] ?? '',
    );
  }
}

class TransactionPage extends StatefulWidget {
  final VoidCallback? onBack;
  const TransactionPage({super.key, this.onBack});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> with TickerProviderStateMixin {
  List<Transaction> transactions = [];
  bool isLoading = true;
  String? errorMessage;


  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
    fetchUserDataAndTransactions();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchUserDataAndTransactions() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final number = await SharedPrefHelper.getPhoneNumber();
      if (number != null) {
        final response = await http.get(Uri.parse(
            'https://pashuparivar.com/api/getprofileByNumber/$number'));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final user = data['result'][0];
          final userId = user['id'].toString();

          await fetchTransactions(userId);
        } else {
          throw Exception('Failed to fetch user data');
        }
      } else {
        throw Exception('User not logged in');
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        errorMessage = l10n.noTransactions;
      });
      print('Error fetching user or transactions: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchTransactions(String userId) async {
    try {
      final response = await http.get(Uri.parse(
          'https://pashuparivar.com/api/payment/transactions/$userId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final txList = data['transactions'] ?? [];

        setState(() {
          transactions = txList.map((e) => Transaction.fromJson(e)).toList();
          // Sort transactions by date (newest first)
          transactions.sort((a, b) => DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt)));
        });
      } else {
        throw Exception('Failed to fetch transactions');
      }
    } catch (e) {
      throw Exception('Error fetching transactions: $e');
    }
  }

  Map<String, String> formatDateTime(String datetime) {
    final l10n = AppLocalizations.of(context)!;
    final date = DateTime.parse(datetime);
    final now = DateTime.now();
    final difference = now.difference(date);

    String dateStr;
    if (difference.inDays == 0) {
      dateStr = l10n.today;
    } else if (difference.inDays == 1) {
      dateStr = l10n.yesterday;
    } else if (difference.inDays < 7) {
      dateStr = l10n.daysAgo(difference.inDays.toString());
    } else {
      dateStr = "${date.day}/${date.month}/${date.year}";
    }

    return {
      'date': dateStr,
      'time': "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}",
      'fullDate': "${date.day}/${date.month}/${date.year}",
    };
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'credit':
        return Icons.add_circle_rounded;
      case 'debit':
        return Icons.remove_circle_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  Color getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'credit':
        return Colors.green;
      case 'debit':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String getLocalizedStatus(String status, AppLocalizations l10n) {
    switch (status.toLowerCase()) {
      case 'success':
        return l10n.success;
      case 'pending':
        return l10n.pending;
      case 'failed':
        return l10n.failed;
      default:
        return status.toUpperCase();
    }
  }

  String getLocalizedType(String type, AppLocalizations l10n) {
    switch (type.toLowerCase()) {
      case 'credit':
        return l10n.credit;
      case 'debit':
        return l10n.debit;
      default:
        return type.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light grayish-white background

      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: fetchUserDataAndTransactions,
          color: AppColors.primaryDark,
          backgroundColor: Colors.white,
          child: _buildContent(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryDark.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryDark.withOpacity(0.2)),
          ),
          child: Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.primaryDark,
            size: 20,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          const AppLogo(size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.transactionHistory,
              style: AppTextStyles.heading.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryDark.withOpacity(0.2)),
            ),
            child: Icon(
              Icons.refresh_rounded,
              color: AppColors.primaryDark,
              size: 20,
            ),
          ),
          onPressed: fetchUserDataAndTransactions,
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return _buildShimmerLoading();
    }

    if (errorMessage != null) {
      return _buildErrorWidget();
    }

    if (transactions.isEmpty) {
      return _buildEmptyWidget();
    }

    return Column(
      children: [
        _buildStatsHeader(),
        Expanded(
          child: SlideTransition(
            position: _slideAnimation,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                return _buildTransactionCard(transactions[index], index);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsHeader() {
    final l10n = AppLocalizations.of(context)!;
    if (transactions.isEmpty) return const SizedBox.shrink();

    double totalCredit = 0;
    double totalDebit = 0;
    int successCount = 0;

    for (var tx in transactions) {
      final amount = double.tryParse(tx.amount) ?? 0;
      if (tx.type.toLowerCase() == 'credit') {
        totalCredit += amount;
      } else {
        totalDebit += amount;
      }
      if (tx.status.toLowerCase() == 'success') {
        successCount++;
      }
    }

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.lightSage.withOpacity(0.1),
            AppColors.lightSage.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryDark,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryDark.withOpacity(0.15),
                      AppColors.primaryDark.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryDark.withOpacity(0.3)),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: AppColors.primaryDark,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  l10n.transactionSummary,
                  style: AppTextStyles.heading.copyWith(
                    color: AppColors.primaryDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildStatItem(l10n.totalCredit, '₹${totalCredit.toInt()}', Colors.green),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(l10n.totalDebit, '₹${totalDebit.toInt()}', Colors.red),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(l10n.successful, '$successCount', Colors.blue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.heading.copyWith(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primaryDark.withOpacity(0.7),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTransactionCard(Transaction transaction, int index) {
    final l10n = AppLocalizations.of(context)!;
    final formatted = formatDateTime(transaction.createdAt);
    final typeColor = getTypeColor(transaction.type);
    final statusColor = getStatusColor(transaction.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.lightSage.withOpacity(0.1),
            AppColors.lightSage.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryDark,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: typeColor.withOpacity(0.3)),
                  ),
                  child: Icon(
                    getTypeIcon(transaction.type),
                    color: typeColor,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '₹${transaction.amount}',
                              style: AppTextStyles.heading.copyWith(
                                color: typeColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: statusColor.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              getLocalizedStatus(transaction.status, l10n),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Text(
                        '${getLocalizedType(transaction.type, l10n)} • ${formatted['date']} at ${formatted['time']}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryDark.withOpacity(0.6),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Details Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryDark.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (transaction.razorpayPaymentId.isNotEmpty)
                    _buildDetailRow(l10n.paymentId, transaction.razorpayPaymentId, l10n),

                  _buildDetailRow(l10n.fullDate, formatted['fullDate']!, l10n),

                  if (transaction.comment.isNotEmpty)
                    _buildDetailRow(
                      transaction.status.toLowerCase() == 'success' ? l10n.utrNumber : l10n.message,
                      transaction.comment,
                      l10n,
                      isLast: true,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, AppLocalizations l10n, {bool isLast = false}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryDark.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            Flexible(
              child: Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 8),
          Container(
            height: 1,
            color: AppColors.primaryDark.withOpacity(0.1),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Stats Header Shimmer
          Shimmer.fromColors(
            baseColor: AppColors.lightSage.withOpacity(0.1),
            highlightColor: AppColors.lightSage.withOpacity(0.2),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryDark, width: 2),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Transaction Cards Shimmer
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: AppColors.lightSage.withOpacity(0.1),
                  highlightColor: AppColors.lightSage.withOpacity(0.2),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primaryDark, width: 2),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.primaryDark.withOpacity(0.5),
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              l10n.failedToLoadTransactions,
              style: AppTextStyles.heading.copyWith(
                color: AppColors.primaryDark,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage ?? l10n.somethingWentWrong,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryDark.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: fetchUserDataAndTransactions,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_rounded,
              color: AppColors.primaryDark.withOpacity(0.5),
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              l10n.noTransactionsFound,
              style: AppTextStyles.heading.copyWith(
                color: AppColors.primaryDark,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.transactionHistoryDescription,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryDark.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              label: Text(l10n.goBack),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
