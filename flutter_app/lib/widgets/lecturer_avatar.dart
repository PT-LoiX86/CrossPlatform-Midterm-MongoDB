import 'package:flutter/material.dart';

import '../config/api_config.dart';

class LecturerAvatar extends StatelessWidget {
  const LecturerAvatar({super.key, this.imagePath, this.radius = 30});

  final String? imagePath;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = ApiConfig.imageUrl(imagePath);

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFE5F1FC),
      foregroundImage: url == null ? null : NetworkImage(url),
      onForegroundImageError: url == null ? null : (_, _) {},
      child: Icon(
        Icons.person_rounded,
        size: radius,
        color: const Color(0xFF3979B8),
      ),
    );
  }
}
