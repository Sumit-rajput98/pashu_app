class InvestModel {
  final int id;
  final int userId;
  final String title;
  final String description;
  final String investmentType;
  final String investmentName;
  final String owner;
  final String address;
  final int projectValue;
  final String duration;
  final String expectedHarvest;
  final String projectStartDate;
  final int totalSlots;
  final int availableSlots;
  final int amountInvested;
  final String investmentDate;
  final String maturityDate;
  final int currentValue;
  final int returnRate;
  final int profitLoss;
  final String brokerName;
  final String accountNumber;
  final String riskLevel;
  final String status;
  final String currency;
  final String documentUrl;
  final String projectImage;
  final String notes;
  final String createdAt;
  final String updatedAt;
  final String projectReport;

  InvestModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.investmentType,
    required this.investmentName,
    required this.owner,
    required this.address,
    required this.projectValue,
    required this.duration,
    required this.expectedHarvest,
    required this.projectStartDate,
    required this.totalSlots,
    required this.availableSlots,
    required this.amountInvested,
    required this.investmentDate,
    required this.maturityDate,
    required this.currentValue,
    required this.returnRate,
    required this.profitLoss,
    required this.brokerName,
    required this.accountNumber,
    required this.riskLevel,
    required this.status,
    required this.currency,
    required this.documentUrl,
    required this.projectImage,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.projectReport,
  });

  factory InvestModel.fromJson(Map<String, dynamic> json) {
    return InvestModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      investmentType: json['investment_type'],
      investmentName: json['investment_name'] ?? '',
      owner: json['owner'],
      address: json['address'],
      projectValue: json['project_value'],
      duration: json['duration'],
      expectedHarvest: json['expected_harvest'],
      projectStartDate: json['project_startdate'],
      totalSlots: json['total_slots'],
      availableSlots: json['available_slots'],
      amountInvested: json['amount_invested'],
      investmentDate: json['investment_date'],
      maturityDate: json['maturity_date'],
      currentValue: json['current_value'],
      returnRate: json['return_rate'],
      profitLoss: json['profit_loss'],
      brokerName: json['broker_name'],
      accountNumber: json['account_number'],
      riskLevel: json['risk_level'],
      status: json['status'],
      currency: json['currency'],
      documentUrl: json['document_url'],
      projectImage: json['project_image'],
      notes: json['notes'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      projectReport: json['project_report'],
    );
  }
}