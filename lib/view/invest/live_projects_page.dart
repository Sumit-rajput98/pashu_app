import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LiveProjectsPage extends StatelessWidget {
  const LiveProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
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
                    'https://www.shutterstock.com/image-photo/golden-trout-fishes-water-tank-600nw-2466648037.jpg',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
        
                // Details
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MVP for aquaculture investment',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E4A59),),
                      ),
                      const SizedBox(height: 10),
        
                      Row(
                        children: const [
                          Icon(Icons.timelapse, size: 20),
                          SizedBox(width: 6),
                          Text("Type: Long Term"),
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
                          Text("Start Date: 1st August 2025"),
                        ],
                      ),
                      const SizedBox(height: 6),
        
                      Row(
                        children: const [
                          Icon(Icons.hourglass_bottom, size: 20),
                          SizedBox(width: 6),
                          Text("Duration: 6 to 8 months"),
                        ],
                      ),
                      const SizedBox(height: 12),
        
                      // Horizontal Vessel Progress
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: 0.15, // 15%
                          minHeight: 12,
                          backgroundColor: Colors.grey.shade300,
                          color: Color(0xFF35C75A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text("23 / 200 Lots Booked"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
