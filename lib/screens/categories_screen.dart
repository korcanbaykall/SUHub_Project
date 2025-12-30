import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../routes.dart';
import 'generic_category_screen.dart';
import '../models/post.dart';
import 'search_results_screen.dart';


class CategoriesScreen extends StatelessWidget {

  final categories = <Map<String, dynamic>>[
    {
      'title': 'Events',
      'icon': Icons.event,
      'route': AppRoutes.events,
    },
    {
      'title': 'Top Posts of Today',
      'icon': Icons.trending_up,
      'route': AppRoutes.topPosts,
    },
    {
      'title': 'Student Clubs',
      'icon': Icons.groups,
      'route': AppRoutes.genericCategory,
    },
    {
      'title': 'Academic Courses',
      'icon': Icons.menu_book,
      'route': AppRoutes.genericCategory,
    },
    {
      'title': 'Dining Options',
      'icon': Icons.restaurant,
      'route': AppRoutes.genericCategory,
    },
    {
      'title': 'Transportation Services',
      'icon': Icons.directions_bus,
      'route': AppRoutes.genericCategory,
    },
    {
      'title': 'Dormitories',
      'icon': Icons.apartment,
      'route': AppRoutes.genericCategory,
    },
    {
      'title': 'Campus Facilities',
      'icon': Icons.location_city,
      'route': AppRoutes.genericCategory,
    },
    {
      'title': 'Social Activities',
      'icon': Icons.celebration,
      'route': AppRoutes.genericCategory,
    },
    {
      'title': 'Other',
      'icon': Icons.more_horiz,
      'route': AppRoutes.genericCategory,
    },
  ];

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
                  Container(
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
                ],
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
                    return ListTile(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.genericCategory,
                          arguments: {
                            'title': 'Student Clubs',
                            'icon': Icons.groups,
                          },
                        );
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
