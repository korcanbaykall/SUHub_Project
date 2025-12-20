import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../routes.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Events':
        return Icons.event;
      case 'Top Posts of Today':
        return Icons.trending_up;
      default:
        return Icons.category;
    }
  }

  void _handleCategoryTap(BuildContext context, String category) {
    if (category == 'Events') {
      Navigator.pushNamed(context, AppRoutes.events);
    } else if (category == 'Top Posts of Today') {
      Navigator.pushNamed(context, AppRoutes.topPosts);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final categories = <String>[
      'Events',
      'Top Posts of Today',
    ];

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
                  Image.asset(
                    'assets/images/logo.png',
                    height: 48,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.98),
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
                    borderSide: BorderSide(color: Colors.blue.shade200),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < categories.length; i++) ...[
                      ListTile(
                        onTap: () => _handleCategoryTap(context, categories[i]),
                        leading: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.9),
                          child: Icon(
                            _iconForCategory(categories[i]),
                            color: Colors.black87,
                          ),
                        ),
                        title: Text(
                          categories[i],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Colors.black54,
                        ),
                      ),
                      if (i != categories.length - 1)
                        const Divider(
                          thickness: 0.8,
                          height: 0,
                          color: Colors.white54,
                          indent: 16,
                          endIndent: 16,
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
