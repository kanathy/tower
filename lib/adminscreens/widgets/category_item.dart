import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  final String title;
  final String? iconPath;
  final IconData? iconData; // Now optional
  final Color backgroundColor;
  final VoidCallback onTap;

  const CategoryItem({
    super.key,
    required this.title,
    this.iconPath,
    this.iconData,
    required this.backgroundColor,
    required this.onTap,
  }) : assert(
         iconPath != null || iconData != null,
         'Either iconPath or iconData must be provided.',
       );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: iconPath != null
                  ? Image.asset(iconPath!, width: 70, height: 70)
                  : Icon(iconData, size: 30, color: Colors.black),
            ),
          ),
          const SizedBox(height: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 73, 27, 109), // Background color
              borderRadius: BorderRadius.circular(8.0), // Rounded corners
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white, // Make text readable on purple background
              ),
            ),
          ),
        ],
      ),
    );
  }
}
