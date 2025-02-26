import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileImage extends StatefulWidget {
  final String? imageUrl;
  final double radius;
  final VoidCallback? onTap;
  final Widget? badge;

  const ProfileImage({
    Key? key,
    this.imageUrl,
    this.radius = 40,
    this.onTap,
    this.badge,
  }) : super(key: key);

  @override
  State<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: widget.radius,
            backgroundColor: Colors.grey[300],
            child: ClipOval(
              child: widget.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: widget.imageUrl!,
                      width: widget.radius * 2,
                      height: widget.radius * 2,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(
                        Icons.person,
                        size: widget.radius,
                        color: Colors.grey[600],
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: widget.radius,
                      color: Colors.grey[600],
                    ),
            ),
          ),
          if (widget.badge != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: widget.badge!,
            ),
        ],
      ),
    );
  }
}
