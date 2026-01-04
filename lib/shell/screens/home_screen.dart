import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../../core/constants/post_categories.dart';
import '../../core/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../posts/models/post.dart';
import '../../posts/providers/posts_provider.dart';
import '../../posts/screens/search_results_screen.dart';
import '../../widgets/create_post_dialog.dart';
import '../../widgets/user_avatar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleCardTap(BuildContext context, String title) {
    if (title == 'Top Posts of Today') {
      Navigator.pushNamed(context, AppRoutes.topPosts);
    } else if (title == "Student Clubs’ Events") {
      Navigator.pushNamed(context, AppRoutes.events);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final profile = auth.profile;
    final user = auth.user;
    final username = profile?.username ?? user?.email ?? 'User';

    return Container(
      width: size.width,
      height: size.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset('assets/images/logo.png', height: 82),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
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
                            setState(() {});
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
                onChanged: (_) => setState(() {}),
                onSubmitted: (query) {
                  final q = query.trim();
                  if (q.isEmpty) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SearchResultsScreen(query: q),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Text(
                'Hello $username!',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Stay tuned!',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.05,
                children: [
                  _ContextCard(
                    title: 'Top Posts of Today',
                    icon: Icons.trending_up,
                    onTap: () => _handleCardTap(context, 'Top Posts of Today'),
                  ),
                  _ContextCard(
                    title: "Student Clubs’ Events",
                    icon: Icons.groups,
                    onTap: () => _handleCardTap(context, "Student Clubs’ Events"),
                  ),
                  _ContextCard(
                    title: 'Finals Are Coming!',
                    icon: Icons.menu_book,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.genericCategory,
                        arguments: {
                          'categoryKey': PostCategories.academicCourses,
                          'icon': Icons.menu_book,
                        },
                      );
                    },
                  ),
                  _ContextCard(
                    title: 'Create Post',
                    icon: Icons.add_circle_outline,
                    onTap: () {
                      final auth = context.read<AuthProvider>();
                      final posts = context.read<PostsProvider>();
                      final user = auth.user;

                      if (user == null) return;

                      final profile = auth.profile;
                      final username =
                          profile?.username ?? user.email ?? 'user';
                      final authorPhotoUrl = profile?.photoUrl ?? '';
                      final authorPhotoAlignX = profile?.photoAlignX ?? 0.0;
                      final authorPhotoAlignY = profile?.photoAlignY ?? 0.0;

                      showDialog(
                        context: context,
                        builder: (_) => CreatePostDialog(
                          onCreate: (text, category, imageUrl) async {
                            await posts.createPost(
                              text: text,
                              category: category,
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
                  ),
                ],
              ),
              const SizedBox(height: 12),

              StreamBuilder<List<Post>>(
                stream: context.read<PostsProvider>().postsStream(),
                builder: (context, snapshot) {
                  final colorScheme = Theme.of(context).colorScheme;
                  final isDark = Theme.of(context).brightness == Brightness.dark;

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _TopCategoryShell(colorScheme: colorScheme, isDark: isDark);
                  }

                  final posts = snapshot.data ?? [];
                  final topResult = _findTopCategoryWithTopPost(posts);

                  if (topResult == null) {
                    return _TopCategoryMessage(
                      colorScheme: colorScheme,
                      isDark: isDark,
                      text: 'Be the first to post to set the trend!',
                    );
                  }

                  final categoryKey = topResult.key;
                  final categoryTitle = topResult.title;
                  final count = topResult.count;
                  final icon = _categoryIcons[categoryKey] ?? Icons.category;
                  final topPost = topResult.topPost;

                  return _TopCategoryCard(
                    colorScheme: colorScheme,
                    isDark: isDark,
                    icon: icon,
                    categoryTitle: categoryTitle,
                    count: count,
                    post: topPost,
                    onCategoryTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.genericCategory,
                        arguments: {
                          'categoryKey': categoryKey,
                          'icon': icon,
                        },
                      );
                    },
                    onPostTap: topPost == null
                        ? null
                        : () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.categoryPostDetail,
                              arguments: topPost.id,
                            );
                          },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContextCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const _ContextCard({
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final card = Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(isDark ? 0.94 : 0.97),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, 4),
            color: Theme.of(context)
                .shadowColor
                .withOpacity(isDark ? 0.3 : 0.08),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Icon(
            icon,
            size: 24,
            color: colorScheme.primary.withOpacity(0.85),
          ),
        ],
      ),
    );

    if (onTap == null) return card;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: card,
    );
  }
}

class _TopCategoryResult {
  final String key;
  final String title;
  final int count;
  final Post? topPost;

  const _TopCategoryResult({
    required this.key,
    required this.title,
    required this.count,
    required this.topPost,
  });
}

class _ResolvedCategory {
  final String key;
  final String title;
  const _ResolvedCategory({required this.key, required this.title});
}

_TopCategoryResult? _findTopCategoryWithTopPost(List<Post> posts) {
  if (posts.isEmpty) return null;

  final Map<String, int> counts = {};
  final Map<String, List<Post>> grouped = {};
  final Map<String, String> keyToTitle = {};

  for (final post in posts) {
    final resolved = _resolveCategory(post.category);
    counts[resolved.key] = (counts[resolved.key] ?? 0) + 1;
    grouped.putIfAbsent(resolved.key, () => []).add(post);
    keyToTitle[resolved.key] = resolved.title;
  }

  if (counts.isEmpty) return null;

  final topKey = counts.entries.reduce(
    (a, b) => b.value > a.value ? b : a,
  ).key;

  final topPosts = posts
      .where((p) => _resolveCategory(p.category).key == topKey)
      .toList();
  final topPost = _selectTopPost(topPosts);

  return _TopCategoryResult(
    key: topKey,
    title: keyToTitle[topKey] ?? _categoryTitleFromKey(topKey),
    count: counts[topKey] ?? topPosts.length,
    topPost: topPost,
  );
}

_ResolvedCategory _resolveCategory(String raw) {
  final lower = raw.toLowerCase();
  final match = PostCategories.titles.entries.firstWhere(
    (e) => e.key.toLowerCase() == lower || e.value.toLowerCase() == lower,
    orElse: () => const MapEntry(PostCategories.other, 'Other'),
  );
  return _ResolvedCategory(key: match.key, title: match.value);
}

String _categoryTitleFromKey(String key) {
  return PostCategories.titles[key] ?? 'Other';
}

Post? _selectTopPost(List<Post> posts) {
  if (posts.isEmpty) return null;
  return posts.reduce((a, b) {
    final scoreA = a.likes + a.comments;
    final scoreB = b.likes + b.comments;
    if (scoreB > scoreA) return b;
    if (scoreB < scoreA) return a;
    final timeA = a.createdAt?.millisecondsSinceEpoch ?? 0;
    final timeB = b.createdAt?.millisecondsSinceEpoch ?? 0;
    return timeB >= timeA ? b : a;
  });
}

const Map<String, IconData> _categoryIcons = {
  PostCategories.studentClubs: Icons.groups,
  PostCategories.academicCourses: Icons.menu_book,
  PostCategories.dining: Icons.restaurant,
  PostCategories.transportation: Icons.directions_bus,
  PostCategories.dormitories: Icons.apartment,
  PostCategories.facilities: Icons.location_city,
  PostCategories.social: Icons.celebration,
  PostCategories.other: Icons.more_horiz,
};

class _TopCategoryCard extends StatelessWidget {
  final ColorScheme colorScheme;
  final bool isDark;
  final IconData icon;
  final String categoryTitle;
  final int count;
  final Post? post;
  final VoidCallback onCategoryTap;
  final VoidCallback? onPostTap;

  const _TopCategoryCard({
    required this.colorScheme,
    required this.isDark,
    required this.icon,
    required this.categoryTitle,
    required this.count,
    required this.post,
    required this.onCategoryTap,
    required this.onPostTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onCategoryTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(isDark ? 0.93 : 0.97),
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
                Icon(icon, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Most posted category: $categoryTitle ($count posts)',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                  size: 22,
                ),
              ],
            ),
            if (post != null) ...[
              const SizedBox(height: 12),
              InkWell(
                onTap: onPostTap,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:
                        colorScheme.surface.withOpacity(isDark ? 0.9 : 0.95),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          UserAvatar(
                            radius: 16,
                            initials: post!.authorUsername,
                            imageUrl: post!.authorPhotoUrl,
                            alignX: post!.authorPhotoAlignX,
                            alignY: post!.authorPhotoAlignY,
                            backgroundColor: colorScheme.surfaceVariant,
                            textColor: colorScheme.onSurface,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post!.authorUsername,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  categoryTitle,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ReactionsRow(post: post!, colorScheme: colorScheme),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        post!.text,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReactionsRow extends StatelessWidget {
  final Post post;
  final ColorScheme colorScheme;

  const _ReactionsRow({
    required this.post,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final color = colorScheme.onSurfaceVariant;
    const size = 16.0;
    final textStyle = TextStyle(
      color: color,
      fontWeight: FontWeight.w700,
      fontSize: 12,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.thumb_up_alt_outlined, size: size, color: color),
        const SizedBox(width: 3),
        Text('${post.likes}', style: textStyle),
        const SizedBox(width: 10),
        Icon(Icons.thumb_down_alt_outlined, size: size, color: color),
        const SizedBox(width: 3),
        Text('${post.dislikes}', style: textStyle),
        const SizedBox(width: 10),
        Icon(Icons.chat_bubble_outline, size: size, color: color),
        const SizedBox(width: 3),
        Text('${post.comments}', style: textStyle),
      ],
    );
  }
}

class _TopCategoryShell extends StatelessWidget {
  final ColorScheme colorScheme;
  final bool isDark;

  const _TopCategoryShell({
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(isDark ? 0.93 : 0.97),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Finding the hottest category...',
            style: TextStyle(
              fontSize: 15,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopCategoryMessage extends StatelessWidget {
  final ColorScheme colorScheme;
  final bool isDark;
  final String text;

  const _TopCategoryMessage({
    required this.colorScheme,
    required this.isDark,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(isDark ? 0.93 : 0.97),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

