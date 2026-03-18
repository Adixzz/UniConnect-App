import 'package:flutter/material.dart';

class ScheduleTile extends StatelessWidget {
  final String name;
  final String time;
  final String type; // "Private" or "Group" (or Module name!)
  final VoidCallback? onTap; // 1. Added the onTap property

  const ScheduleTile({
    super.key,
    required this.name,
    required this.time,
    required this.type,
    this.onTap, // 2. Added to the constructor
  });

  @override
  Widget build(BuildContext context) {
    // Define colors based on the meeting type tag
    final bool isPrivate = type.toLowerCase() == "private";
    final Color tagBgColor = isPrivate
        ? Colors.grey.shade100
        : Colors.blue.shade50;
    final Color tagTextColor = isPrivate
        ? Colors.grey.shade700
        : Colors.blue.shade700;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // 3. Wrapped with Material and InkWell for a beautiful tap ripple effect!
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            15,
          ), // Keeps the ripple inside the rounded edges
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // 1. Icon Container (Blue circle from your design)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.access_time_filled,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // 2. Name and Time Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        time,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Tag (Private/Group/Module Name)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: tagBgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300, width: 0.5),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      color: tagTextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
