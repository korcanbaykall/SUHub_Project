import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key});

  bool _isNetworkImage(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final args = ModalRoute.of(context)?.settings.arguments;
    final data = (args is Map<String, dynamic>) ? args : <String, dynamic>{};

    final String title = (data['title'] ?? 'Sabancı Seahawks Match') as String;
    final String date = (data['date'] ?? '24.01.2026') as String;
    final String imageAsset =
    (data['imageAsset'] ?? 'assets/images/seahawks.png') as String;
    final String details = (data['details'] ??
        'We take the field at home, in front of our own fans, on January 24!\n\n'
            'Every play, every battle is an opportunity to show the Sabancı Seahawks spirit!\n\n'
            'With all our energy, we’re on the field against Akdeniz Heroes! 💙') as String;

    return Scaffold(
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.04,
              vertical: size.height * 0.025,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: size.width * 0.055,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: size.height * 0.006),
                          Text(
                            date,
                            style: TextStyle(
                              fontSize: size.width * 0.04,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Container(
                      padding: EdgeInsets.all(size.width * 0.015),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: size.width * 0.13,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: size.height * 0.015),

                /// BACK BUTTON
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: size.width * 0.045,
                      ),
                      SizedBox(width: size.width * 0.015),
                      Text(
                        'Back',
                        style: TextStyle(
                          fontSize: size.width * 0.04,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: size.height * 0.025),

                /// IMAGE
                Container(
                  width: double.infinity,
                  height: size.height * 0.28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _isNetworkImage(imageAsset)
                      ? Image.network(imageAsset, fit: BoxFit.cover)
                      : Image.asset(imageAsset, fit: BoxFit.cover),
                ),

                SizedBox(height: size.height * 0.03),

                /// DETAILS TITLE
                Text(
                  'Details',
                  style: TextStyle(
                    fontSize: size.width * 0.05,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: size.height * 0.012),

                /// DETAILS TEXT
                Text(
                  details,
                  style: TextStyle(
                    fontSize: size.width * 0.04,
                    color: Colors.white,
                    height: 1.5,
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
