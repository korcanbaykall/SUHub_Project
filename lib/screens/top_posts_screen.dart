import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../providers/auth_provider.dart';
import '../providers/posts_provider.dart';
import '../routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/create_post_dialog.dart';

class TopPostsScreen extends StatelessWidget {
  const TopPostsScreen({super.key});

  Future<void> _openCreateDialog(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final posts = context.read<PostsProvider>();

    final user = auth.user!;
    final username = auth.profile?.username ?? (user.email ?? 'user');

    final created = await showDialog<bool>(
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

    if (!context.mounted) return;
    if (created == true && posts.error != null) {
      // Provider error (rare)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(posts.error!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final postsProvider = context.watch<PostsProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final user = auth.user;
    if (user == null) {
      // AuthGate normally prevents this, but safety:
      return const Scaffold(
        body: Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Posts of Today'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<List<Post>>(
          stream: postsProvider.postsStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: AppTextStyles.bodyWhite,
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final posts = snapshot.data!;
            if (posts.isEmpty) {
              return const Center(
                child: Text(
                  'No posts yet. Create the first one!',
                  style: AppTextStyles.bodyWhite,
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: posts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final p = posts[i];
                final isOwner = p.createdBy == user.uid;

                return _PostCard(
                  post: p,
                  isOwner: isOwner,
                  colorScheme: colorScheme,
                  isDark: isDark,
                  userId: user.uid,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.topPostDetail,
                      arguments: p.id,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: postsProvider.busy ? null : () => _openCreateDialog(context),
        child: postsProvider.busy
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;
  final bool isOwner;
  final ColorScheme colorScheme;
  final bool isDark;
  final String userId;
  final VoidCallback onTap;

  const _PostCard({
    required this.post,
    required this.isOwner,
    required this.colorScheme,
    required this.isDark,
    required this.userId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(isDark ? 0.94 : 0.97),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 6),
              color:
                  Theme.of(context).shadowColor.withOpacity(isDark ? 0.3 : 0.08),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header line
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colorScheme.surfaceVariant,
                  child: Text(
                    post.authorUsername.isNotEmpty
                        ? post.authorUsername[0].toUpperCase()
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
            const SizedBox(height: 10),

            Text(
              post.text,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Footer stats (UI only for now)
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
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(width: 14),
                Icon(
                  Icons.thumb_down_alt_outlined,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.dislikes}',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(width: 14),
                Icon(
                  Icons.chat_bubble_outline,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.comments}',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                const Spacer(),
                if (isOwner)
                  Text(
                    'My post',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CreatePostDialog extends StatefulWidget {
  final Future<void> Function(String text, String category) onCreate;

  const _CreatePostDialog({required this.onCreate});

  @override
  State<_CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<_CreatePostDialog> {
  final TextEditingController _textController = TextEditingController();
  String _category = 'General';
  bool _saving = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _saving) return;

    setState(() => _saving = true);
    await widget.onCreate(text, _category);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Post'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _textController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Text',
              hintText: 'Write something...',
            ),
          ),
          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            value: _category,
            items: const [
              DropdownMenuItem(value: 'Dormitories', child: Text('Dormitories')),
              DropdownMenuItem(value: 'Dining Options', child: Text('Dining Options')),
              DropdownMenuItem(value: 'Transportation Services', child: Text('Transportation Services')),
              DropdownMenuItem(value: 'Student Clubs', child: Text('Student Clubs')),
              DropdownMenuItem(value: 'Academic Courses', child: Text('Academic Courses')),
              DropdownMenuItem(value: 'Campus Facilities', child: Text('Campus Facilities')),
              DropdownMenuItem(value: 'Social Activities', child: Text('Social Activities')),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
            ],
            onChanged: (v) => setState(() => _category = v!),
            decoration: const InputDecoration(labelText: 'Category'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _handleCreate,
          child: Text(_saving ? 'Please wait...' : 'Create'),
        ),
      ],
    );
  }
}
