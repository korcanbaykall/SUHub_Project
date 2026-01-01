import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../providers/posts_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/routes.dart';

class SearchResultsScreen extends StatelessWidget {
  final String query;

  const SearchResultsScreen({
    super.key,
    required this.query,
  });

  List<Post> _filterPosts(List<Post> posts) {
    final q = query.toLowerCase();
    return posts.where((post) {
      return post.text.toLowerCase().contains(q) ||
          post.category.toLowerCase().contains(q) ||
          post.authorUsername.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final postsProvider = context.watch<PostsProvider>();
    final colorScheme = Theme.of(context).colorScheme;


    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
        elevation: 0,
        backgroundColor:
        isDark ? theme.colorScheme.surface : Colors.white,
        foregroundColor: theme.colorScheme.onSurface,
      ),


      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<List<Post>>(
          stream: postsProvider.postsStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: AppTextStyles.bodyWhite,
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final results = _filterPosts(snapshot.data!);

            if (results.isEmpty) {
              return const Center(
                child: Text(
                  'No results found',
                  style: AppTextStyles.bodyWhite,
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: results.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You searched for:',
                        style: AppTextStyles.bodyWhite,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '"$query"',
                        style: AppTextStyles.appTitle,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${results.length} results found',
                        style: AppTextStyles.bodyWhite,
                      ),
                    ],
                  );
                }

                final p = results[i - 1];

                return _SearchPostCard(
                  post: p,
                  colorScheme: colorScheme,
                  isDark: isDark,
                  highlight: query,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.topPostDetail,
                      arguments: p.id,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SearchPostCard extends StatelessWidget {
  final Post post;
  final ColorScheme colorScheme;
  final bool isDark;
  final String highlight;
  final VoidCallback onTap;

  const _SearchPostCard({
    required this.post,
    required this.colorScheme,
    required this.isDark,
    required this.highlight,
    required this.onTap,
  });

  TextSpan _highlightText(String text, TextStyle base) {
    final q = highlight.toLowerCase();
    final t = text.toLowerCase();
    final idx = t.indexOf(q);

    if (idx == -1 || highlight.isEmpty) {
      return TextSpan(text: text, style: base);
    }

    return TextSpan(
      children: [
        TextSpan(text: text.substring(0, idx), style: base),
        TextSpan(
          text: text.substring(idx, idx + highlight.length),
          style: base.copyWith(color: colorScheme.error),
        ),
        TextSpan(text: text.substring(idx + highlight.length), style: base),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(isDark ? 0.94 : 0.97),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 6),
              color: Theme.of(context)
                  .shadowColor
                  .withOpacity(isDark ? 0.3 : 0.08),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colorScheme.surfaceVariant,
                  child: Text(
                    post.authorUsername.isNotEmpty
                        ? post.authorUsername[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    post.authorUsername,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    post.category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Post text with highlight
            RichText(
              text: _highlightText(
                post.text,
                TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

