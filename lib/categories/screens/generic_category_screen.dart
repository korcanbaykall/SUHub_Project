import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../posts/models/post.dart';
import '../../auth/providers/auth_provider.dart';
import '../../posts/providers/posts_provider.dart';
import '../../core/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/create_post_dialog.dart';
import '../../widgets/post_image.dart';
import '../../widgets/user_avatar.dart';
import '../../core/constants/post_categories.dart';

class GenericCategoryScreen extends StatefulWidget {
  const GenericCategoryScreen({super.key});

  @override
  State<GenericCategoryScreen> createState() => _GenericCategoryScreenState();
}

class _GenericCategoryScreenState extends State<GenericCategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Post> _filterPosts(List<Post> posts, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return posts;

    return posts.where((post) {
      return post.text.toLowerCase().contains(normalized) ||
          post.authorUsername.toLowerCase().contains(normalized);
    }).toList();
  }

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
    final profile = auth.profile;
    final username = profile?.username ?? user?.email ?? 'user';
    final authorPhotoUrl = profile?.photoUrl ?? '';
    final authorPhotoAlignX = profile?.photoAlignX ?? 0.0;
    final authorPhotoAlignY = profile?.photoAlignY ?? 0.0;

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
              onCreate: (text, _, imageUrl) async {
                await postsProvider.createPost(
                  text: text,
                  category: categoryTitle,
                  createdBy: user.uid,
                  authorUsername: username,
                  authorPhotoUrl: authorPhotoUrl,
                  authorPhotoAlignX: authorPhotoAlignX,
                  authorPhotoAlignY: authorPhotoAlignY,
                  imageUrl: imageUrl,
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _query = '';
                            });
                          },
                        ),
                  filled: true,
                  fillColor:
                      colorScheme.surface.withOpacity(isDark ? 0.9 : 0.98),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: colorScheme.primary),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _query = value;
                  });
                },
              ),
            ),
            Expanded(
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

                  final filteredPosts = _filterPosts(posts, _query);
                  if (filteredPosts.isEmpty) {
                    return const Center(
                      child: Text(
                        'No posts match your search.',
                        style: AppTextStyles.bodyWhite,
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: filteredPosts.length,
                    itemBuilder: (context, i) {
                      final post = filteredPosts[i];

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

                              Row(
                                children: [
                                  Icon(
                                    Icons.thumb_up_alt_outlined,
                                    size: 18,
                                    color: colorScheme.onSurfaceVariant,
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
                                    Icons.thumb_down_alt_outlined,
                                    size: 18,
                                    color: colorScheme.onSurfaceVariant,
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
          ],
        ),
      ),
    );
  }
}
