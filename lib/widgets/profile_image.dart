import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileImage extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final VoidCallback? onTap;
  final Widget? badge; // Yeni: Badge widget için (doğrulanmış işareti vb.)

  const ProfileImage({
    super.key,
    this.imageUrl,
    this.radius = 40,
    this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey[200],
            backgroundImage: imageUrl != null
                ? CachedNetworkImageProvider(imageUrl!) as ImageProvider
                : AssetImage('assets/default_profile.png'),
          ),
          if (badge != null)
            Positioned(
              bottom: 0,
              right: 0,
              child: badge!,
            ),
        ],
      ),
    );
  }
}
