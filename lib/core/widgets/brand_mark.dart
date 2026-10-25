import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.yellow,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.holiday_village_outlined, size: 25),
        ),
        const SizedBox(width: 12),
        Text.rich(
          const TextSpan(
            children: [
              TextSpan(text: 'campus '),
              TextSpan(
                text: 'bobo',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text: '.',
                style: TextStyle(color: AppColors.yellow),
              ),
            ],
          ),
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }
}
