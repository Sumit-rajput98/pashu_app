import 'package:flutter/material.dart';
import '../../../model/invest/invest_model.dart';


class ProjectLotSelectorWidget extends StatelessWidget {
  final InvestModel project;
  final int selectedLots;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onProceed;

  const ProjectLotSelectorWidget({
    super.key,
    required this.project,
    required this.selectedLots,
    required this.onIncrement,
    required this.onDecrement,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E4A59),
            ),
          ),
          const SizedBox(height: 10),

          Text(
            project.description,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),

          const Text(
            "Select Lots",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              IconButton(
                onPressed: onDecrement,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text('$selectedLots', style: const TextStyle(fontSize: 16)),
              IconButton(
                onPressed: onIncrement,
                icon: const Icon(Icons.add_circle_outline),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.money),
              const SizedBox(width: 6),
              Text("Total Investment: ₹${selectedLots * 1}"),
            ],
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onProceed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF35C75A),
              ),
              child: const Text("Proceed To Payment", style: TextStyle(color: Colors.white),),
            ),
          ),
        ],
      ),
    );
  }
}
