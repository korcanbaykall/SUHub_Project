import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/posts_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../routes.dart';
import '../widgets/create_post_dialog.dart';
import 'search_results_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 96,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
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
              const SizedBox(height: 18),
              const SizedBox(height: 4),
              const Text(
                'TOP CONTEXTS',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.7,
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
                          'title': 'Academic Courses',
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

                      final username =
                          auth.profile?.username ?? user.email ?? 'user';

                      showDialog(
                        context: context,
                        builder: (_) => CreatePostDialog(
                          onCreate: (text, category) async {
                            await posts.createPost(
                              text: text,
                              category: category,
                              createdBy: user.uid,
                              authorUsername: username,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(isDark ? 0.94 : 0.97),
        borderRadius: BorderRadius.circular(22),
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
            size: 30,
            color: colorScheme.primary.withOpacity(0.85),
          ),
        ],
      ),
    );

    if (onTap == null) return card;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: card,
    );
  }
}
