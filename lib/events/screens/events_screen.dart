import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../../core/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../models/event.dart';
import '../providers/events_provider.dart';
import '../widgets/create_event_dialog.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Event> _filterEvents(List<Event> events, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return events;

    return events.where((event) {
      final title = event.title.toLowerCase();
      final date = event.date.toLowerCase();
      final details = event.details.toLowerCase();
      return title.contains(normalized) ||
          date.contains(normalized) ||
          details.contains(normalized);
    }).toList();
  }

  Future<void> _openCreateDialog(BuildContext context) async {
    final events = context.read<EventsProvider>();

    final created = await showDialog<bool>(
      context: context,
      builder: (_) => CreateEventDialog(
        onSubmit: ({
          required String title,
          required String date,
          required String imageUrl,
          required String details,
        }) async {
          await events.createEvent(
            title: title,
            date: date,
            imageUrl: imageUrl,
            details: details,
          );
        },
      ),
    );

    if (!context.mounted) return;
    if (created == true && events.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(events.error!)),
      );
    }
  }

  Future<void> _openEditDialog(BuildContext context, Event event) async {
    final events = context.read<EventsProvider>();

    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => CreateEventDialog(
        dialogTitle: 'Edit Event',
        submitLabel: 'Save',
        initialTitle: event.title,
        initialDate: event.date,
        initialImageUrl: event.imageUrl,
        initialDetails: event.details,
        onSubmit: ({
          required String title,
          required String date,
          required String imageUrl,
          required String details,
        }) async {
          await events.updateEvent(
            id: event.id,
            title: title,
            date: date,
            imageUrl: imageUrl,
            details: details,
          );
        },
      ),
    );

    if (!context.mounted) return;
    if (updated == true && events.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(events.error!)),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, Event event) async {
    final events = context.read<EventsProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Event'),
          content: Text('Delete "${event.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    await events.deleteEvent(event.id);
    if (!context.mounted) return;
    if (events.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(events.error!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final eventsProvider = context.watch<EventsProvider>();
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAdmin = auth.profile?.role == 'admin';

    return Scaffold(
      body: Container(
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Üst başlık + logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Events',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 60,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _query = '';
                              });
                            },
                          ),
                    filled: true,
                    fillColor:
                        colorScheme.surface.withOpacity(isDark ? 0.9 : 0.98),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: colorScheme.primary),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _query = value;
                    });
                  },
                ),
                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: const [
                        Icon(Icons.arrow_back, color: Colors.white, size: 20),
                        SizedBox(width: 4),
                        Text(
                          'Back',
                          style: AppTextStyles.bodyWhite,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: StreamBuilder<List<Event>>(
                    stream: eventsProvider.eventsStream(),
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

                      final events = snapshot.data!;
                      if (events.isEmpty) {
                        return const Center(
                          child: Text(
                            'No events yet.',
                            style: AppTextStyles.bodyWhite,
                          ),
                        );
                      }

                      final filteredEvents = _filterEvents(events, _query);
                      if (filteredEvents.isEmpty) {
                        return const Center(
                          child: Text(
                            'No events match your search.',
                            style: AppTextStyles.bodyWhite,
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: filteredEvents.length,
                        itemBuilder: (context, index) {
                          final event = filteredEvents[index];
                          return _EventCard(
                            event: event,
                            isAdmin: isAdmin,
                            onEdit: () => _openEditDialog(context, event),
                            onDelete: () => _confirmDelete(context, event),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => _openCreateDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  final bool isAdmin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EventCard({
    required this.event,
    required this.isAdmin,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(isDark ? 0.93 : 0.95),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 110,
            height: 110,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.network(
              event.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (isAdmin)
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          onSelected: (value) {
                            if (value == 'edit') {
                              onEdit();
                            } else if (value == 'delete') {
                              onDelete();
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.date,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.eventDetail,
                          arguments: event.toDetailMap(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Details',
                        style: TextStyle(color: colorScheme.onPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
