import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../providers/auth_provider.dart';
import '../providers/posts_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class TopPostDetailScreen extends StatelessWidget {
  const TopPostDetailScreen({super.key});

  Future<void> _openEditDialog(BuildContext context, Post post) async {
    final postsProvider = context.read<PostsProvider>();

    final textController = TextEditingController(text: post.text);
    String category = post.category;

    final updated = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Text',
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
                onChanged: (v) => category = v ?? category,
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
                final newText = textController.text.trim();
                if (newText.isEmpty) return;

                await postsProvider.updatePost(
                  id: post.id,
                  text: newText,
                  category: category,
                );

                if (ctx.mounted) Navigator.pop(ctx, true);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    textController.dispose();

    if (updated == true && postsProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(postsProvider.error!)),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, String postId) async {
    final postsProvider = context.read<PostsProvider>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    await postsProvider.deletePost(postId);

    if (postsProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(postsProvider.error!)),
      );
      return;
    }

    if (context.mounted) Navigator.pop(context); // back to list
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final postsProvider = context.watch<PostsProvider>();

    final user = auth.user;

    final args = ModalRoute.of(context)?.settings.arguments;
    final postId = args is String ? args : null;

    if (postId == null) {
      return const Scaffold(
        body: Center(child: Text('Post id is missing.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Detail'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<Post>(
          stream: postsProvider.postStream(postId),
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

            final post = snapshot.data!;
            final isOwner = user != null && post.createdBy == user.uid;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
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
                        // Header
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
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
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
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

                        const SizedBox(height: 14),

                        // Content
                        Text(
                          post.text,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 16),
                        const Divider(height: 18),

                        // Stats (UI)
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
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Owner actions
                  if (isOwner) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: postsProvider.busy
                                ? null
                                : () => _openEditDialog(context, post),
                            icon: const Icon(Icons.edit),
                            label: postsProvider.busy
                                ? const Text('Please wait...')
                                : const Text('Edit'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: postsProvider.busy
                                ? null
                                : () => _confirmDelete(context, post.id),
                            icon: const Icon(Icons.delete),
                            label: postsProvider.busy
                                ? const Text('Please wait...')
                                : const Text('Delete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Only the owner can edit or delete this post.',
                        style: AppTextStyles.bodyWhite,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
