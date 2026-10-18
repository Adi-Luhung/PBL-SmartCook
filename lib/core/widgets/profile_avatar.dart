import 'dart:io';

import 'package:flutter/material.dart';

import '../services/profile_photo_service.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.radius = 18,
    this.iconSize = 20,
  });

  final double radius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ProfilePhotoService.instance,
      builder: (context, _) {
        final path = ProfilePhotoService.instance.photoPath;
        if (path != null && File(path).existsSync()) {
          return CircleAvatar(
            radius: radius,
            backgroundImage: FileImage(File(path)),
          );
        }
        return CircleAvatar(
          radius: radius,
          backgroundColor: const Color(0xFFE2E8F0),
          child: Icon(
            Icons.person,
            color: const Color(0xFF94A3B8),
            size: iconSize,
          ),
        );
      },
    );
  }
}
