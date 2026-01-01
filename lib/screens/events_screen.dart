import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final events = <_Event>[
      _Event(
        title: 'SuSnow Palandöken',
        date: '18.12.2025',
        imageAsset:
            'https://cdn3.enuygun.com/media/lib/1x720/uploads/image/dedeman-palandoken-erzurum-one-cikan-resim-76402883.webp',
        details:
            'Winter holiday and ski event! Details will be announced soon.',
      ),
      _Event(
        title: 'Radyosu New Year Party',
        date: '30.12.2025',
        imageAsset: 'https://kutlamamarketi.com/img/cms/parti.png',
        details:
            'New Year’s party! Music, fun, and surprises. Details coming soon.',
      ),
      _Event(
        title: 'Sabancı Seahawks Match',
        date: '24.01.2026',
        imageAsset:
            'https://upload.wikimedia.org/wikipedia/commons/4/44/2004_Vanderbilt-Navy_Game_TE.jpg',
        details:
        'We take the field at home, in front of our own fans, on January 24!\n\n'
            'Every play, every battle is an opportunity to show the Sabancı Seahawks spirit!\n\n'
            'With all our energy, we’re on the field against Akdeniz Heroes! 💙'
        ,
      ),
    ];

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
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search),
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
                  child: ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return _EventCard(event: event);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Event {
  final String title;
  final String date;
  final String imageAsset;
  final String details;

  _Event({
    required this.title,
    required this.date,
    required this.imageAsset,
    required this.details,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'date': date,
        'imageAsset': imageAsset,
        'details': details,
      };
}

class _EventCard extends StatelessWidget {
  final _Event event;

  const _EventCard({required this.event});

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
              event.imageAsset,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
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
                          arguments: event.toMap(),
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
