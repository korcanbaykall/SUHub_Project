import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../auth/providers/auth_provider.dart' as app_auth;
import '../../shell/providers/theme_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _usernameCtrl = TextEditingController();
  final _oldPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();

  String? _passwordError;

  @override
  void initState() {
    super.initState();
    final auth = context.read<app_auth.AuthProvider>();
    _usernameCtrl.text = auth.profile?.username ?? '';
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _oldPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<app_auth.AuthProvider>();
    final theme = context.watch<ThemeProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Column(
                  children: [
                  _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Change Password',
                          style: AppTextStyles.subtitle),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _oldPasswordCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Old password',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _newPasswordCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'New password',
                          errorText: _passwordError,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () async {
                            final email = auth.user?.email;
                            if (email == null) return;

                            await FirebaseAuth.instance
                                .sendPasswordResetEmail(email: email);

                            if (!mounted) return;

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Password reset email sent'),
                              ),
                            );
                          },
                          child: const Text('Forgot password?'),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: auth.isLoading
                              ? null
                              : () async {
                            final newPass =
                                _newPasswordCtrl.text;

                            if (newPass.length < 6) {
                              setState(() {
                                _passwordError =
                                'Minimum 6 characters';
                              });
                              return;
                            }

                            setState(() => _passwordError = null);

                            await auth.changePassword(
                              oldPassword:
                              _oldPasswordCtrl.text,
                              newPassword: newPass,
                            );

                            if (!mounted) return;

                            if (auth.error == null) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Password updated'),
                                ),
                              );
                              _oldPasswordCtrl.clear();
                              _newPasswordCtrl.clear();
                            } else {
                              setState(() {
                                _passwordError = auth.error;
                              });
                            }
                          },
                          child: const Text('Change Password'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _card(
                  child: SwitchListTile.adaptive(
                    value: theme.isDark,
                    onChanged: theme.setDark,
                    title: const Text(
                      'Dark mode',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle:
                    const Text('Saved locally on device'),
                    secondary: Icon(
                      theme.isDark
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: colorScheme.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: auth.isLoading
                        ? null
                        : () async {
                      await auth.signOut();
                    },
                    icon: const Icon(Icons.logout),
                    label: Text(
                      auth.isLoading
                          ? 'Logging out...'
                          : 'Logout',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      colorScheme.errorContainer,
                      foregroundColor:
                      colorScheme.onErrorContainer,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ],
          ),
        ),
      )
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surface
            .withOpacity(0.95),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 6),
            color: Colors.black.withOpacity(0.08),
          ),
        ],
      ),
      child: child,
    );
  }
}
