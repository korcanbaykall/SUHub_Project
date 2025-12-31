import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    Navigator.of(context).popUntil((route) => route.isFirst);
    await context.read<AuthProvider>().signOut();
    // AuthGate otomatik olarak Welcome'a döndürür.
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final auth = context.watch<AuthProvider>();

    final user = auth.user;
    final profile = auth.profile;

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
          child: user == null
              ? _LoggedOutView()
              : _LoggedInView(
                  username: profile?.username ?? 'User',
                  email: user.email ?? '-',
                  uid: user.uid,
                  isLoading: auth.isLoading,
                  error: auth.error,
                  onLogout: () => _logout(context),
                ),
        ),
      ),
    );
  }
}

class _LoggedOutView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Profile', style: AppTextStyles.appTitle.copyWith(fontSize: 26)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface.withOpacity(0.85),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            'You are not logged in.',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.signin),
            icon: const Icon(Icons.login),
            label: const Text('Go to Sign In'),
          ),
        ),
      ],
    );
  }
}

class _LoggedInView extends StatelessWidget {
  final String username;
  final String email;
  final String uid;
  final bool isLoading;
  final String? error;
  final VoidCallback onLogout;

  const _LoggedInView({
    required this.username,
    required this.email,
    required this.uid,
    required this.isLoading,
    required this.error,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Profile',
              style: AppTextStyles.appTitle.copyWith(fontSize: 26),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.isDark ? Colors.black : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Image.asset('assets/images/logo.png', height: 60),
            ),
          ],
        ),
        const SizedBox(height: 18),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface.withOpacity(theme.isDark ? 0.94 : 0.97),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                offset: const Offset(0, 6),
                color: Theme.of(context)
                    .shadowColor
                    .withOpacity(theme.isDark ? 0.3 : 0.08),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: colorScheme.surfaceVariant,
                    child: Text(
                      username.isNotEmpty ? username[0].toUpperCase() : 'U',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 18),
              _InfoRow(label: 'User ID', value: uid),
              const SizedBox(height: 10),
              _InfoRow(label: 'Email', value: email),
            ],
          ),
        ),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.editProfile,
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              'Settings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),


        if (error != null) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              error!,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          flex: 7,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
