import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/routes.dart';
import '../../posts/screens/search_results_screen.dart';
import '../../core/constants/post_categories.dart';
import '../../auth/providers/auth_provider.dart';
import '../../posts/providers/posts_provider.dart';
import '../../widgets/create_post_dialog.dart';


class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();

  final categories = <Map<String, dynamic>>[
    {
      'title': 'Events',
      'icon': Icons.event,
      'route': AppRoutes.events,
      'categoryKey': PostCategories.events,
    },
    {
      'title': 'Top Posts of Today',
      'icon': Icons.trending_up,
      'route': AppRoutes.topPosts,
      'categoryKey': PostCategories.topPosts,
    },
    {
      'title': 'Student Clubs',
      'icon': Icons.groups,
      'route': AppRoutes.genericCategory,
      'categoryKey': PostCategories.studentClubs,
    },
    {
      'title': 'Academic Courses',
      'icon': Icons.menu_book,
      'route': AppRoutes.genericCategory,
      'categoryKey': PostCategories.academicCourses,
    },
    {
      'title': 'Dining Options',
      'icon': Icons.restaurant,
      'route': AppRoutes.genericCategory,
      'categoryKey': PostCategories.dining,
    },
    {
      'title': 'Transportation Services',
      'icon': Icons.directions_bus,
      'route': AppRoutes.genericCategory,
      'categoryKey': PostCategories.transportation,
    },
    {
      'title': 'Dormitories',
      'icon': Icons.apartment,
      'route': AppRoutes.genericCategory,
      'categoryKey': PostCategories.dormitories,
    },
    {
      'title': 'Campus Facilities',
      'icon': Icons.location_city,
      'route': AppRoutes.genericCategory,
      'categoryKey': PostCategories.facilities,
    },
    {
      'title': 'Social Activities',
      'icon': Icons.celebration,
      'route': AppRoutes.genericCategory,
      'categoryKey': PostCategories.social,
    },
    {
      'title': 'Other',
      'icon': Icons.more_horiz,
      'route': AppRoutes.genericCategory,
      'categoryKey': PostCategories.other,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final postsProvider = context.watch<PostsProvider>();
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = auth.user;
    final profile = auth.profile;
    final username = profile?.username ?? user?.email ?? 'user';
    final authorPhotoUrl = profile?.photoUrl ?? '';
    final authorPhotoAlignX = profile?.photoAlignX ?? 0.0;
    final authorPhotoAlignY = profile?.photoAlignY ?? 0.0;

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
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories',
                    style: AppTextStyles.appTitle.copyWith(fontSize: 26),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () {
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please log in to create a post.'),
                          ),
                        );
                        return;
                      }

                      showDialog(
                        context: context,
                        builder: (_) => CreatePostDialog(
                          onCreate: (text, category) async {
                            await postsProvider.createPost(
                              text: text,
                              category: category,
                              createdBy: user.uid,
                              authorUsername: username,
                              authorPhotoUrl: authorPhotoUrl,
                              authorPhotoAlignX: authorPhotoAlignX,
                              authorPhotoAlignY: authorPhotoAlignY,
                            );
                          },
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 60,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

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
              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(isDark ? 0.9 : 0.22),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  separatorBuilder: (context, index) => Divider(
                    thickness: 0.8,
                    height: 0,
                    color: colorScheme.outlineVariant,
                    indent: 16,
                    endIndent: 16,
                  ),
                  itemBuilder: (context, i) {
                    final item = categories[i];
                    return ListTile(
                      onTap: () {
                        final route = item['route'];

                        if (route == AppRoutes.genericCategory) {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.genericCategory,
                            arguments: {
                              'title': item['title'],
                              'icon': item['icon'],
                              'categoryKey': item['categoryKey'],
                            },
                          );
                        } else {
                          Navigator.pushNamed(context, route);
                        }
                      },

                      leading: CircleAvatar(
                        backgroundColor: colorScheme.surfaceVariant,
                        child: Icon(
                          categories[i]['icon'],
                          color: colorScheme.onSurface,
                        ),
                      ),
                      title: Text(
                        categories[i]['title'],
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
