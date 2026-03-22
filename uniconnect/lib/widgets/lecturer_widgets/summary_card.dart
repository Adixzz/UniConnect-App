import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title, count;
  final IconData icon;
  final Color color;
  final double cardWidth; 

  const SummaryCard({
    super.key, 
    required this.title, 
    required this.count, 
    required this.icon, 
    required this.color,
    this.cardWidth = 110, 
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cardWidth, 
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            count, 
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 4),
          Text(
            title, 
            style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)
          ),
        ],
      ),
    );
  }
}