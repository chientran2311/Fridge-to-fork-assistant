import 'package:flutter/material.dart';

class FridgeSectionHeader extends StatelessWidget {
  final String title;

  const FridgeSectionHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}