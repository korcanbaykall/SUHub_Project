import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../auth/providers/auth_provider.dart' as app_auth;
import '../../auth/screens/auth_gate.dart';
import '../../shell/providers/theme_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/user_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _usernameCtrl = TextEditingController();
  final _oldPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _photoUrlCtrl = TextEditingController();

  String? _passwordError;
  String? _photoUrl;
  double _photoAlignX = 0.0;
  double _photoAlignY = 0.0;
  bool _photoBusy = false;
  bool _profileLoaded = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<app_auth.AuthProvider>();
    _usernameCtrl.text = auth.profile?.username ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_profileLoaded) return;
    final profile = context.read<app_auth.AuthProvider>().profile;
    if (profile == null) return;
    if (_usernameCtrl.text.isEmpty) {
      _usernameCtrl.text = profile.username;
    }
    _photoUrl = profile.photoUrl ?? '';
    _photoUrlCtrl.text = profile.photoUrl ?? '';
    _photoAlignX = profile.photoAlignX ?? 0.0;
    _photoAlignY = profile.photoAlignY ?? 0.0;
    _profileLoaded = true;
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _oldPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _photoUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _savePhotoSettings() async {
    final auth = context.read<app_auth.AuthProvider>();
    final user = auth.user;
    final currentUrl = _photoUrl ?? _photoUrlCtrl.text.trim();
    if (user == null || _photoBusy) return;

    setState(() => _photoBusy = true);
    try {
      setState(() => _photoUrl = currentUrl);
      await auth.updateProfilePhoto(
        photoUrl: currentUrl,
        photoAlignX: _photoAlignX,
        photoAlignY: _photoAlignY,
      );
      if (!mounted) return;
      if (auth.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo saved')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.error!)),
        );
      }
    } finally {
      if (mounted) setState(() => _photoBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<app_auth.AuthProvider>();
    final theme = context.watch<ThemeProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final profile = auth.profile;
    final username = profile?.username ?? _usernameCtrl.text;
    final avatarUrl = _photoUrl ?? profile?.photoUrl ?? '';

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
                        Text(
                          'Profile Photo',
                          style: AppTextStyles.subtitle.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            UserAvatar(
                              radius: 36,
                              initials: username,
                              imageUrl: avatarUrl,
                              alignX: _photoAlignX,
                              alignY: _photoAlignY,
                              backgroundColor: colorScheme.surfaceVariant,
                              textColor: colorScheme.onSurface,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                avatarUrl.isEmpty
                                    ? 'No photo yet. Paste a URL to replace initials.'
                                    : 'Drag the sliders to pick the focus point.',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _photoUrlCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Photo URL',
                            hintText: 'https://example.com/me.jpg',
                          ),
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          onChanged: (value) {
                            final trimmed = value.trim();
                            setState(() => _photoUrl = trimmed);
                          },
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _photoBusy ? null : _savePhotoSettings,
                            icon: const Icon(Icons.save),
                            label: Text(_photoBusy ? 'Saving...' : 'Save photo'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Photo position',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Horizontal',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        Slider(
                          value: _photoAlignX,
                          min: -1,
                          max: 1,
                          divisions: 20,
                          onChanged: avatarUrl.isEmpty || _photoBusy
                              ? null
                              : (value) => setState(() => _photoAlignX = value),
                        ),
                        Text(
                          'Vertical',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        Slider(
                          value: _photoAlignY,
                          min: -1,
                          max: 1,
                          divisions: 20,
                          onChanged: avatarUrl.isEmpty || _photoBusy
                              ? null
                              : (value) => setState(() => _photoAlignY = value),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: avatarUrl.isEmpty || _photoBusy
                                ? null
                                : _savePhotoSettings,
                            child: Text(
                              _photoBusy ? 'Saving...' : 'Save photo position',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Change Password',
                        style: AppTextStyles.subtitle.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
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
                      if (!mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const AuthGate()),
                        (route) => false,
                      );
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
