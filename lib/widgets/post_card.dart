import 'package:flutter/material.dart';
import '../posts/models/post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final String highlight;

  const PostCard({
    super.key,
    required this.post,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle normalStyle =
        Theme.of(context).textTheme.bodyMedium ??
            const TextStyle(fontSize: 14);

    final TextStyle highlightStyle = normalStyle.copyWith(
      color: Colors.red,
      fontWeight: FontWeight.w600,
    );

    final TextStyle metaStyle =
        Theme.of(context).textTheme.bodySmall ??
            const TextStyle(fontSize: 12, color: Colors.grey);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: _highlightText(
                post.text,
                highlight,
                normalStyle,
                highlightStyle,
              ),
            ),

            const SizedBox(height: 10),

            RichText(
              text: _highlightText(
                "@${post.authorUsername} • ${post.category}",
                highlight,
                metaStyle,
                metaStyle.copyWith(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextSpan _highlightText(
      String text,
      String query,
      TextStyle normalStyle,
      TextStyle highlightStyle,
      ) {
    if (query.isEmpty) {
      return TextSpan(text: text, style: normalStyle);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    final startIndex = lowerText.indexOf(lowerQuery);

    if (startIndex == -1) {
      return TextSpan(text: text, style: normalStyle);
    }

    final endIndex = startIndex + query.length;

    return TextSpan(
      children: [
        TextSpan(
          text: text.substring(0, startIndex),
          style: normalStyle,
        ),
        TextSpan(
          text: text.substring(startIndex, endIndex),
          style: highlightStyle,
        ),
        TextSpan(
          text: text.substring(endIndex),
          style: normalStyle,
        ),
      ],
    );
  }
}
