import 'package:flutter/material.dart';
import '../../model/invest/invest_model.dart';

import 'invest_details_page.dart';

class InvestProjectItem extends StatelessWidget {
  final InvestModel project;

  const InvestProjectItem({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final bookedRatio = (project.totalSlots - project.availableSlots) / project.totalSlots;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InvestDetailsPage(project: project),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.green.shade50,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                ),
                child: Image.network(
                  'https://pashuparivar.com/uploads/${project.projectImage}',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E4A59)),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(Icons.timelapse, size: 20),
                        const SizedBox(width: 6),
                        Text("Type: ${project.investmentType}"),
                      ],
                    ),
                    const SizedBox(height: 6),

                    Row(
                      children: const [
                        Icon(Icons.money, size: 20),
                        SizedBox(width: 6),
                        Text("Amount: ₹1"),
                      ],
                    ),
                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(Icons.calendar_month, size: 20),
                        const SizedBox(width: 6),
                        Text("Start Date: ${project.projectStartDate.substring(0, 10)}"),
                      ],
                    ),
                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(Icons.hourglass_bottom, size: 20),
                        const SizedBox(width: 6),
                        Text("Duration: ${project.duration}"),
                      ],
                    ),
                    const SizedBox(height: 12),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: bookedRatio,
                        minHeight: 12,
                        backgroundColor: Colors.grey.shade300,
                        color: const Color(0xFF35C75A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text("${project.totalSlots - project.availableSlots} / ${project.totalSlots} Lots Booked"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
