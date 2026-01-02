import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String initials;
  final String? imageUrl;
  final double radius;
  final double alignX;
  final double alignY;
  final Color? backgroundColor;
  final Color? textColor;

  const UserAvatar({
    super.key,
    required this.initials,
    this.imageUrl,
    this.radius = 20,
    this.alignX = 0.0,
    this.alignY = 0.0,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? scheme.surfaceVariant;
    final fg = textColor ?? scheme.onSurface;
    final initial = initials.isNotEmpty ? initials[0].toUpperCase() : 'U';

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: Container(
          width: radius * 2,
          height: radius * 2,
          color: bg,
          child: Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            alignment: Alignment(alignX, alignY),
            errorBuilder: (_, __, ___) => Center(
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: radius * 0.8,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}
