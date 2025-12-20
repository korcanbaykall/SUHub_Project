import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../providers/auth_provider.dart';
import '../providers/posts_provider.dart';
import '../routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class TopPostsScreen extends StatelessWidget {
  const TopPostsScreen({super.key});

  Future<void> _openCreateDialog(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final posts = context.read<PostsProvider>();

    final user = auth.user!;
    final username = auth.profile?.username ?? (user.email ?? 'user');

    final textController = TextEditingController();
    String category = 'General';

    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Create Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Text',
                  hintText: 'Write something...',
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: category,
                items: const [
                  DropdownMenuItem(value: 'General', child: Text('General')),
                  DropdownMenuItem(value: 'Campus', child: Text('Campus')),
                  DropdownMenuItem(value: 'Clubs', child: Text('Clubs')),
                  DropdownMenuItem(value: 'Midterms', child: Text('Midterms')),
                ],
                onChanged: (v) => category = v ?? 'General',
                decoration: const InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final text = textController.text.trim();
                if (text.isEmpty) return;

                await posts.createPost(
                  text: text,
                  category: category,
                  createdBy: user.uid,
                  authorUsername: username,
                );

                if (ctx.mounted) Navigator.pop(ctx, true);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    textController.dispose();

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
  final VoidCallback onTap;

  const _PostCard({
    required this.post,
    required this.isOwner,
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
          color: Colors.white.withOpacity(0.97),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 6),
              color: Colors.black.withOpacity(0.08),
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
                  backgroundColor: Colors.black.withOpacity(0.06),
                  child: Text(
                    post.authorUsername.isNotEmpty
                        ? post.authorUsername[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    post.authorUsername,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    post.category,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Text(
              post.text,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Footer stats (UI only for now)
            Row(
              children: [
                const Icon(Icons.thumb_up_alt_outlined, size: 18),
                const SizedBox(width: 4),
                Text('${post.likes}'),
                const SizedBox(width: 14),
                const Icon(Icons.thumb_down_alt_outlined, size: 18),
                const SizedBox(width: 4),
                Text('${post.dislikes}'),
                const SizedBox(width: 14),
                const Icon(Icons.chat_bubble_outline, size: 18),
                const SizedBox(width: 4),
                Text('${post.comments}'),
                const Spacer(),
                if (isOwner)
                  const Text(
                    'My post',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
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
