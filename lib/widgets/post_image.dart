import 'dart:convert';

import 'package:flutter/material.dart';

Widget buildPostImage({
  required String imageUrl,
  required double height,
  required BorderRadius borderRadius,
}) {
  if (imageUrl.isEmpty) {
    return const SizedBox.shrink();
  }

  final Widget image;
  if (imageUrl.startsWith('data:image') && imageUrl.contains('base64,')) {
    try {
      final base64Data = imageUrl.split('base64,').last;
      final bytes = base64Decode(base64Data);
      image = Image.memory(
        bytes,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  } else {
    image = Image.network(
      imageUrl,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const SizedBox.shrink();
      },
    );
  }

  return ClipRRect(
    borderRadius: borderRadius,
    child: image,
  );
}
