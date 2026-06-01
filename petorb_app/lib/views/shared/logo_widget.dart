import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class PetOrbLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isHorizontal;
  final Color? textColor;

  const PetOrbLogo({
    super.key,
    this.size = 80.0,
    this.showText = true,
    this.isHorizontal = false,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget logoIcon = ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.25),
      child: Image.asset(
        'assets/logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Robust Custom-painted fallback container in case asset fails
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: AppColors.mainGradient,
              borderRadius: BorderRadius.circular(size * 0.25),
            ),
            child: Center(
              child: Text(
                'P',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.55,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Outfit',
                ),
              ),
            ),
          );
        },
      ),
    );

    if (!showText) return logoIcon;

    if (isHorizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          logoIcon,
          const SizedBox(width: 12),
          Text(
            'PetOrb',
            style: TextStyle(
              fontSize: size * 0.38,
              fontWeight: FontWeight.w800,
              color: textColor ?? AppColors.primaryText,
              fontFamily: 'Outfit',
              letterSpacing: 0.5,
            ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          logoIcon,
          const SizedBox(height: 16),
          Text(
            'PetOrb',
            style: TextStyle(
              fontSize: size * 0.35,
              fontWeight: FontWeight.w800,
              color: textColor ?? AppColors.primaryText,
              fontFamily: 'Outfit',
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Intelligent Pet Care Ecosystem',
            style: TextStyle(
              fontSize: size * 0.14,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
              fontFamily: 'Outfit',
            ),
          ),
        ],
      );
    }
  }
}
