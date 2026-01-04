import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../../core/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../posts/models/post.dart';
import '../../posts/providers/posts_provider.dart';
import '../../widgets/post_image.dart';
import '../../widgets/user_avatar.dart';

class MyPostsScreen extends StatelessWidget {
  const MyPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final postsProvider = context.watch<PostsProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final user = auth.user;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posts'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
                  'Something went wrong.',
                  style: AppTextStyles.bodyWhite,
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final posts =
                snapshot.data!.where((p) => p.createdBy == user.uid).toList();

            if (posts.isEmpty) {
              return const Center(
                child: Text(
                  'You have no posts yet.',
                  style: AppTextStyles.bodyWhite,
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: posts.length,
              itemBuilder: (context, i) {
                final post = posts[i];

                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.categoryPostDetail,
                      arguments: post.id,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface
                          .withOpacity(isDark ? 0.94 : 0.97),
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
                        Row(
                          children: [
                            UserAvatar(
                              radius: 18,
                              initials: post.authorUsername,
                              imageUrl: post.authorPhotoUrl,
                              alignX: post.authorPhotoAlignX,
                              alignY: post.authorPhotoAlignY,
                              backgroundColor: colorScheme.surfaceVariant,
                              textColor: colorScheme.onSurface,
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
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
                        const SizedBox(height: 12),
                        if (post.imageUrl.isNotEmpty) ...[
                          buildPostImage(
                            imageUrl: post.imageUrl,
                            height: 180,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          const SizedBox(height: 12),
                        ],
                        Text(
                          post.text,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        StreamBuilder<String?>(
                          stream: postsProvider.reactionStream(post.id, user.uid),
                          builder: (context, reactionSnap) {
                            final reaction = reactionSnap.data;
                            final liked = reaction == 'like';
                            final disliked = reaction == 'dislike';

                            return Row(
                              children: [
                                Icon(
                                  liked
                                      ? Icons.thumb_up_alt
                                      : Icons.thumb_up_alt_outlined,
                                  size: 18,
                                  color: liked
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${post.likes}',
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  disliked
                                      ? Icons.thumb_down_alt
                                      : Icons.thumb_down_alt_outlined,
                                  size: 18,
                                  color: disliked
                                      ? colorScheme.error
                                      : colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${post.dislikes}',
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 18,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${post.comments}',
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
