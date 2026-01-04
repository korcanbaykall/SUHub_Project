import 'package:flutter/material.dart';

class CreateEventDialog extends StatefulWidget {
  final Future<void> Function({
    required String title,
    required String date,
    required String imageUrl,
    required String details,
  }) onSubmit;
  final String dialogTitle;
  final String submitLabel;
  final String? initialTitle;
  final String? initialDate;
  final String? initialImageUrl;
  final String? initialDetails;

  const CreateEventDialog({
    super.key,
    required this.onSubmit,
    this.dialogTitle = 'Create Event',
    this.submitLabel = 'Create',
    this.initialTitle,
    this.initialDate,
    this.initialImageUrl,
    this.initialDetails,
  });

  @override
  State<CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends State<CreateEventDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle ?? '';
    _dateController.text = widget.initialDate ?? '';
    _imageUrlController.text = widget.initialImageUrl ?? '';
    _detailsController.text = widget.initialDetails ?? '';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day.$month.$year';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      initialDate: now,
    );

    if (picked == null) return;
    _dateController.text = _formatDate(picked);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _imageUrlController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    final title = _titleController.text.trim();
    final date = _dateController.text.trim();
    final imageUrl = _imageUrlController.text.trim();
    final details = _detailsController.text.trim();

    if (title.isEmpty || date.isEmpty || imageUrl.isEmpty || details.isEmpty) {
      return;
    }

    if (_submitting) return;
    setState(() => _submitting = true);

    await widget.onSubmit(
      title: title,
      date: date,
      imageUrl: imageUrl,
      details: details,
    );

    if (!mounted) return;
    Navigator.of(context).pop(true);
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
            Text(
              widget.dialogTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dateController,
              readOnly: true,
              onTap: _pickDate,
              decoration: const InputDecoration(
                labelText: 'Date',
                hintText: 'DD.MM.YYYY',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _detailsController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Details'),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _submitting ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _submitting ? null : _handleCreate,
                  child: Text(
                    _submitting ? 'Saving...' : widget.submitLabel,
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
