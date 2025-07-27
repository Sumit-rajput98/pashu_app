import 'package:flutter/material.dart';

import '../../../model/invest/invest_model.dart';


class ProjectOverviewWidget extends StatelessWidget {
  final InvestModel project;

  const ProjectOverviewWidget({super.key, required this.project});

  Widget _buildRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              key,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline),
              SizedBox(width: 8),
              Text(
                "Project Overview",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildRow("Owner:", project.owner),
          _buildRow("Investment Type:", project.investmentType),
          _buildRow("Address:", project.address),
          _buildRow("Project Value:", "₹${project.projectValue}"),
          _buildRow("ROI:", "N/A"),
          _buildRow("Lot Price:", "₹1"),
          _buildRow("Available Lots:", "${project.availableSlots}"),
          _buildRow("Start Time:", project.projectStartDate.substring(0, 10)),
          _buildRow("Harvest Time:", project.expectedHarvest.substring(0, 10)),
          _buildRow("Duration:", project.duration),
          _buildRow("Project Manager Contact:", project.notes),
        ],
      ),
    );
  }
}
