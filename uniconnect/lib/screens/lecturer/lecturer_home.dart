import 'package:flutter/material.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/request_card.dart';
import '../../widgets/ScheduleTile.dart';

class LecturerHomeScreen extends StatelessWidget {
  const LecturerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Good Morning", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const Text("Dr. Sandev", style: TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 25),
              
              // 1. Summary Row Widget
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SummaryCard(title: "Today", count: "3", icon: Icons.calendar_today, color: Colors.blue, cardWidth: 120),
                  SummaryCard(title: "Pending", count: "2", icon: Icons.error_outline, color: Colors.orange, cardWidth: 120),
                  SummaryCard(title: "Students", count: "45", icon: Icons.people_outline, color: Colors.green, cardWidth: 120),
                ],
              ),
              const SizedBox(height: 30),

              const Text("Today's Schedule", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              
              // 2. Schedule Items
              const ScheduleTile(name: "John Smith", time: "10:00 AM - 10:30 AM", type: "Private"),
              const ScheduleTile(name: "Group Meeting", time: "2:00 PM - 3:00 PM", type: "Group"),

              const SizedBox(height: 30),
              const Text("Pending Requests", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              // 3. Request Action Card
              const RequestActionCard(name: "Lisa Anderson", reason: "Exam preparation help"),
            ],
          ),
        ),
      ),
      
    );
  }
}