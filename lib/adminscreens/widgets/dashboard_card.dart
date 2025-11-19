// File: lib/widgets/dashboard_card.dart
// (Or lib/screens/adminpanel/widgets/dashboard_card.dart if you prefer to keep it local to adminpanel)

import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String? iconPath; // For asset images
  final IconData? iconData; // For Flutter Icons
  final Color? iconColor; // Color for the iconData if used
  final Color backgroundColor;
  final VoidCallback onTap;

  const DashboardCard({
    super.key,
    required this.title,
    this.iconPath,
    this.iconData,
    this.iconColor,
    required this.backgroundColor,
    required this.onTap,
  }) : assert(
         iconPath != null || iconData != null,
         'Either iconPath or iconData must be provided.',
       );

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0, // Slight shadow for depth
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0), // Rounded corners
      ),
      color: backgroundColor, // Background color from design
      child: InkWell(
        // Provides a ripple effect on tap
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0), // Match card border radius
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Center content vertically
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                    230,
                    230,
                    230,
                    255,
                  ), // White background for the icon circle
                ),
                child: Image.asset(
                  iconPath!,
                  width: 140,
                  height: 100,
                ), // Display image asset
              ),
              const SizedBox(height: 8.0), // Space between icon and text
              Text(
                title,
                textAlign: TextAlign.center, // Center text
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 73, 27, 109),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
