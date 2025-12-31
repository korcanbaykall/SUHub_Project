import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../providers/auth_provider.dart';
import '../providers/posts_provider.dart';
import '../routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/create_post_dialog.dart';
import '../constants/post_categories.dart';

class GenericCategoryScreen extends StatelessWidget {
  const GenericCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final String categoryKey = args['categoryKey'];
    final String title = PostCategories.titles[categoryKey]!;
    final IconData icon = args['icon'];
    final categoryTitle = PostCategories.titles[categoryKey]!;

    final postsProvider = context.watch<PostsProvider>();
    final auth = context.watch<AuthProvider>();

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final user = auth.user;
    final username =
        auth.profile?.username ?? user?.email ?? 'user';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: user == null
            ? null
            : () {
          showDialog(
            context: context,
            builder: (_) => CreatePostDialog(
              presetCategory: categoryTitle,
              onCreate: (text, _) async {
                await postsProvider.createPost(
                  text: text,
                  category: categoryTitle,
                  createdBy: user.uid,
                  authorUsername: username,
                );
              },
            ),
          );
        },
        child: const Icon(Icons.add),
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
          stream: postsProvider.postsByCategoryStream(categoryTitle),
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
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final posts = snapshot.data!;

            if (posts.isEmpty) {
              return Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surface
                        .withOpacity(isDark ? 0.94 : 0.97),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 42,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Be the first to post!',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
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
                            CircleAvatar(
                              radius: 18,
                              backgroundColor:
                              colorScheme.surfaceVariant,
                              child: Text(
                                post.authorUsername.isNotEmpty
                                    ? post.authorUsername[0]
                                    .toUpperCase()
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color:
                                colorScheme.surfaceVariant,
                                borderRadius:
                                BorderRadius.circular(999),
                              ),
                              child: Text(
                                post.category,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color:
                                  colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Text(
                          post.text,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Icon(
                              Icons.thumb_up_alt_outlined,
                              size: 18,
                              color:
                              colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${post.likes}',
                              style: TextStyle(
                                color: colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 18,
                              color:
                              colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${post.comments}',
                              style: TextStyle(
                                color: colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
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
