import 'package:flutter/material.dart';



class SectionHeader extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SectionHeader({
    required this.title, 
    required this.children
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The grey section title
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        // The list of shopping items
        ...children,
      ],
    );
  }
}
