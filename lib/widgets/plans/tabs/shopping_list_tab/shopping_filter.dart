import 'package:flutter/material.dart';


class CategoryFilters extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: const [
        FilterChip(text: "All Items", active: true),
        FilterChip(text: "Produce"),
        FilterChip(text: "Dairy"),
        FilterChip(text: "Pantry"),
      ],
    );
  }
}

class FilterChip extends StatelessWidget {
  final String text;
  final bool active;

  const FilterChip({required this.text, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF214130) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}