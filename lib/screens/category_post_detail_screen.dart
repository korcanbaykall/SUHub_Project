import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../providers/auth_provider.dart';
import '../providers/posts_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/create_post_dialog.dart';

class CategoryPostDetailScreen extends StatelessWidget {
  const CategoryPostDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final postId = ModalRoute.of(context)!.settings.arguments as String;

    final postsProvider = context.watch<PostsProvider>();
    final auth = context.watch<AuthProvider>();

    final user = auth.user;
    final username = auth.profile?.username ?? user?.email ?? 'user';

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<Post>(
      stream: postsProvider.postStream(postId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final post = snapshot.data!;
        final isOwner = user != null && post.createdBy == user.uid;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Post Detail'),
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
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withOpacity(isDark ? 0.94 : 0.97),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 12,
                        offset: const Offset(0, 8),
                        color: Theme.of(context)
                            .shadowColor
                            .withOpacity(isDark ? 0.35 : 0.10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header (avatar + username + category pill)
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
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

                      const SizedBox(height: 12),

                      Text(
                        post.text,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Divider(
                        thickness: 1,
                        height: 24,
                        color: colorScheme.outline.withOpacity(0.35),
                      ),

                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.thumb_up_alt_outlined,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            onPressed: user == null
                                ? null
                                : () => postsProvider.toggleReaction(
                              postId: post.id,
                              uid: user.uid,
                              type: 'like',
                            ),
                          ),
                          Text(
                            '${post.likes}',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: Icon(
                              Icons.thumb_down_alt_outlined,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            onPressed: user == null
                                ? null
                                : () => postsProvider.toggleReaction(
                              postId: post.id,
                              uid: user.uid,
                              type: 'dislike',
                            ),
                          ),
                          Text(
                            '${post.dislikes}',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
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
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                if (isOwner)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => CreatePostDialog(
                                  initialText: post.text,
                                  presetCategory: post.category,
                                  onCreate: (text, category) async {
                                    await postsProvider.updatePost(
                                      id: post.id,
                                      text: text,
                                      category: category,
                                    );
                                  },
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Delete post?'),
                                  content: const Text(
                                    'This action cannot be undone.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true) {
                                await postsProvider.deletePost(post.id);
                                if (context.mounted) Navigator.pop(context);
                              }
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text('Delete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade300,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 14),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Comments',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),

                      if (user != null)
                        Row(
                          children: [
                            Expanded(
                              child: _CommentInput(
                                colorScheme: colorScheme,
                                onSubmit: (text) async {
                                  if (text.trim().isEmpty) return;
                                  await postsProvider.addComment(
                                    postId: post.id,
                                    text: text.trim(),
                                    createdBy: user.uid,
                                    authorUsername: username,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                              ),
                              onPressed: null,
                            ),
                          ],
                        ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),

                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: postsProvider.streamComments(post.id),
                    builder: (context, snap) {
                      if (!snap.hasData) return const SizedBox();

                      final comments = snap.data!;
                      if (comments.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [Text( 'No comments yet.',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                                fontSize: 13,
                              ),
                            ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: comments.length,
                        itemBuilder: (context, i) {
                          final c = comments[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surface.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (c['authorUsername'] ?? 'user').toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  (c['text'] ?? '').toString(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CommentInput extends StatefulWidget {
  final ColorScheme colorScheme;
  final Future<void> Function(String text) onSubmit;

  const _CommentInput({
    required this.colorScheme,
    required this.onSubmit,
  });

  @override
  State<_CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<_CommentInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    await widget.onSubmit(trimmed);
    if (mounted) _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Write a comment...',
        filled: true,
        fillColor: widget.colorScheme.surface.withOpacity(0.95),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      onSubmitted: _submit,
      textInputAction: TextInputAction.send,
    );
  }
}
