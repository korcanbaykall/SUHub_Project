import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/comment.dart';
import '../models/post.dart';
import '../providers/auth_provider.dart';
import '../providers/posts_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class TopPostDetailScreen extends StatelessWidget {
  const TopPostDetailScreen({super.key});

  Future<void> _openEditDialog(BuildContext context, Post post) async {
    final postsProvider = context.read<PostsProvider>();

    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => _EditPostDialog(
        initialText: post.text,
        initialCategory: post.category,
        onSave: (text, category) async {
          await postsProvider.updatePost(
            id: post.id,
            text: text,
            category: category,
          );
        },
      ),
    );

    if (!context.mounted) return;
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
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
            final userId = user?.uid ?? '';

            void showError() {
              final msg = postsProvider.error;
              if (msg == null) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(msg)),
              );
            }

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
                      color: colorScheme.surface.withOpacity(isDark ? 0.94 : 0.97),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                          color: Theme.of(context)
                              .shadowColor
                              .withOpacity(isDark ? 0.3 : 0.08),
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

                        const SizedBox(height: 14),

                        // Content
                        Text(
                          post.text,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 16),
                        Divider(
                          height: 18,
                          color: colorScheme.outlineVariant,
                        ),

                        // Stats (UI)
                        Row(
                          children: [
                            StreamBuilder<String?>(
                              stream: userId.isEmpty
                                  ? const Stream<String?>.empty()
                                  : postsProvider.reactionStream(post.id, userId),
                              builder: (context, reactionSnap) {
                                final reaction = reactionSnap.data;
                                final liked = reaction == 'like';
                                final disliked = reaction == 'dislike';

                                return Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        liked
                                            ? Icons.thumb_up_alt
                                            : Icons.thumb_up_alt_outlined,
                                        size: 18,
                                        color: liked
                                            ? colorScheme.primary
                                            : colorScheme.onSurfaceVariant,
                                      ),
                                      onPressed: userId.isEmpty
                                          ? null
                                          : () async {
                                              await postsProvider.toggleReaction(
                                                postId: post.id,
                                                uid: userId,
                                                type: 'like',
                                              );
                                              if (context.mounted) showError();
                                            },
                                    ),
                                    Text(
                                      '${post.likes}',
                                      style: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(
                                        disliked
                                            ? Icons.thumb_down_alt
                                            : Icons.thumb_down_alt_outlined,
                                        size: 18,
                                        color: disliked
                                            ? colorScheme.error
                                            : colorScheme.onSurfaceVariant,
                                      ),
                                      onPressed: userId.isEmpty
                                          ? null
                                          : () async {
                                              await postsProvider.toggleReaction(
                                                postId: post.id,
                                                uid: userId,
                                                type: 'dislike',
                                              );
                                              if (context.mounted) showError();
                                            },
                                    ),
                                    Text(
                                      '${post.dislikes}',
                                      style: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
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
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
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
                              backgroundColor: colorScheme.error,
                              foregroundColor: colorScheme.onError,
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
                        color: colorScheme.surface.withOpacity(isDark ? 0.9 : 0.22),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Only the owner can edit or delete this post.',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 18),

                  Text(
                    'Comments',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),

                  _CommentComposer(
                    enabled: user != null,
                    onSubmit: (text) async {
                      if (user == null) return;
                      final username = auth.profile?.username ?? (user.email ?? 'user');
                      await postsProvider.addComment(
                        postId: post.id,
                        text: text,
                        createdBy: user.uid,
                        authorUsername: username,
                      );
                      if (context.mounted) showError();
                    },
                  ),

                  const SizedBox(height: 12),

                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: postsProvider.commentsStream(post.id),
                    builder: (context, commentSnap) {
                      if (!commentSnap.hasData) {
                        return const SizedBox.shrink();
                      }

                      final comments = commentSnap.data!
                          .map((c) => Comment.fromMap(c))
                          .toList();

                      if (comments.isEmpty) {
                        return Text(
                          'No comments yet.',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        );
                      }

                      return Column(
                        children: comments
                            .map(
                              (c) => Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface
                                      .withOpacity(isDark ? 0.94 : 0.97),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: colorScheme.outlineVariant,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.authorUsername,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      c.text,
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CommentComposer extends StatefulWidget {
  final bool enabled;
  final Future<void> Function(String text) onSubmit;

  const _CommentComposer({
    required this.enabled,
    required this.onSubmit,
  });

  @override
  State<_CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends State<_CommentComposer> {
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    await widget.onSubmit(text);
    if (!mounted) return;
    _controller.clear();
    setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            enabled: widget.enabled && !_sending,
            decoration: InputDecoration(
              hintText: widget.enabled ? 'Write a comment...' : 'Sign in to comment',
              filled: true,
              fillColor: colorScheme.surface.withOpacity(isDark ? 0.9 : 0.98),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colorScheme.primary),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: widget.enabled && !_sending ? _handleSend : null,
          icon: Icon(
            Icons.send,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class _EditPostDialog extends StatefulWidget {
  final String initialText;
  final String initialCategory;
  final Future<void> Function(String text, String category) onSave;

  const _EditPostDialog({
    required this.initialText,
    required this.initialCategory,
    required this.onSave,
  });

  @override
  State<_EditPostDialog> createState() => _EditPostDialogState();
}

class _EditPostDialogState extends State<_EditPostDialog> {
  late final TextEditingController _textController;
  late String _category;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _category = widget.initialCategory;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final newText = _textController.text.trim();
    if (newText.isEmpty || _saving) return;

    setState(() => _saving = true);
    await widget.onSave(newText, _category);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Post'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _textController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Text',
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _category,
            items: const [
              DropdownMenuItem(value: 'General', child: Text('General')),
              DropdownMenuItem(value: 'Campus', child: Text('Campus')),
              DropdownMenuItem(value: 'Clubs', child: Text('Clubs')),
              DropdownMenuItem(value: 'Midterms', child: Text('Midterms')),
            ],
            onChanged: (v) => setState(() => _category = v ?? _category),
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
          onPressed: _saving ? null : _handleSave,
          child: Text(_saving ? 'Please wait...' : 'Save'),
        ),
      ],
    );
  }
}
