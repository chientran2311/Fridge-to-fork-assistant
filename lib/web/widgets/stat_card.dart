import 'package:flutter/material.dart';
import '../theme/app_color.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subText;
  final IconData icon;
  final Color color;
  final bool isPositive;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subText,
    required this.icon,
    required this.color,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header: Title + Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title, 
                  style: const TextStyle(color: AppColors.textGrey, fontSize: 13), 
                  overflow: TextOverflow.ellipsis
                )
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6)
                ),
                child: Icon(icon, color: color, size: 18)
              )
            ],
          ),
          // Value
          Text(
            value, 
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark)
          ),
          // Subtext (Trend)
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12, fontFamily: 'Roboto'),
              children: [
                TextSpan(
                  text: subText.split(' ')[0] + ' ',
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold
                  )
                ),
                TextSpan(
                  text: subText.substring(subText.indexOf(' ')),
                  style: const TextStyle(color: AppColors.textGrey)
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}