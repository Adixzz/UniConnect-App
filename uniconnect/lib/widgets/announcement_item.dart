import 'package:flutter/material.dart';

class AnnouncementItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String timeAgo;
  final bool isImportant;

  const AnnouncementItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    this.isImportant = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: Color(0xFFF3E8FF),
          child: Icon(
            Icons.groups_2_outlined,
            color: Colors.purple,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                timeAgo,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        if (isImportant)
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Important',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const Icon(Icons.chevron_right, color: Colors.grey),
      ],
    );
  }
}