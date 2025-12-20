import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'routes.dart';

import 'providers/auth_provider.dart';
import 'providers/posts_provider.dart';
import 'providers/tab_provider.dart';

import 'screens/auth_gate.dart';
import 'theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SUHubApp());
}

class SUHubApp extends StatelessWidget {
  const SUHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PostsProvider()),
        ChangeNotifierProvider(create: (_) => TabProvider()),
      ],
      child: MaterialApp(
        title: 'SUHub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          useMaterial3: true,
        ),
        home: const AuthGate(),
        routes: AppRoutes.routes,
      ),
    );
  }
}
