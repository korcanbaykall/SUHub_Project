import 'package:flutter/material.dart';

class CreatePostDialog extends StatefulWidget {
  final String? presetCategory;
  final Future<void> Function(String text, String category) onCreate;

  final String? initialText;

  const CreatePostDialog({
    super.key,
    required this.onCreate,
    this.presetCategory,
    this.initialText,
  });

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  final TextEditingController _textController = TextEditingController();
  String _category = 'Dormitories';
  bool _submitting = false;

  final List<String> _categories = const [
  'Student Clubs',
  'Academic Courses',
  'Dining Options',
  'Transportation Services',
  'Dormitories',
  'Campus Facilities',
  'Social Activities',
  'Other',
  ];

  @override
  void initState() {
    super.initState();
    _textController.text = widget.initialText ?? '';
    _category = widget.presetCategory ?? 'Other';
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _submitting) return;

    setState(() => _submitting = true);
    await widget.onCreate(text, _category);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Post',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),

            // Text input
            TextField(
              controller: _textController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Text',
              ),
            ),
            const SizedBox(height: 14),

            if (widget.presetCategory != null) ...[
              Text(
                'Category',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).hintColor,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _category,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ] else ...[
              DropdownButtonFormField<String>(
                value: _category,
                items: _categories
                    .map(
                      (c) => DropdownMenuItem(
                    value: c,
                    child: Text(c),
                  ),
                )
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? _category),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
            ],

            const SizedBox(height: 20),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                  _submitting ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _submitting ? null : _handleCreate,
                  child: Text(_submitting ? 'Creating...' : 'Create'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
