import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    this.backgroundColor = AppColors.paleYellow,
  });

  final IconData icon;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: AppColors.ink, size: 24),
    );
  }
}
