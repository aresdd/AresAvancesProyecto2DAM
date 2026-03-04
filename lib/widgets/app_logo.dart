import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// App logo widget (SVG asset).
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.26),
      child: SvgPicture.asset(
        'assets/logo.svg',
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholderBuilder: (_) => SizedBox(
          width: size,
          height: size,
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

