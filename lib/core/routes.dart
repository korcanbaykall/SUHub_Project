import 'package:flutter/material.dart';

import '../auth/screens/welcome_screen.dart';
import '../auth/screens/signin_screen.dart';
import '../auth/screens/signup_screen.dart';

import '../events/screens/events_screen.dart';
import '../events/screens/event_detail_screen.dart';

import '../posts/screens/top_posts_screen.dart';
import '../posts/screens/top_post_detail_screen.dart';

import '../categories/screens/category_post_detail_screen.dart';
import '../categories/screens/generic_category_screen.dart';

import '../profile/screens/edit_profile_screen.dart';
import '../profile/screens/my_posts_screen.dart';

class AppRoutes {
  // Auth / entry
  static const String welcome = '/welcome';
  static const String signup = '/signup';
  static const String signin = '/signin';

  // Feature routes
  static const home = '/';

  static const String events = '/events';
  static const String eventDetail = '/event_detail';

  static const String topPosts = '/top_posts';
  static const String topPostDetail = '/top_post_detail';

  static const String categoryPostDetail = '/category_post_detail';
  static const genericCategory = '/generic-category';

  static const editProfile = '/edit-profile';
  static const myPosts = '/my-posts';


  static Map<String, WidgetBuilder> routes = {
    welcome: (_) => const WelcomeScreen(),
    signup: (_) => const SignupScreen(),
    signin: (_) => const SigninScreen(),

    events: (_) => const EventsScreen(),
    eventDetail: (_) => const EventDetailScreen(),

    topPosts: (_) => const TopPostsScreen(),
    topPostDetail: (_) => const TopPostDetailScreen(),

    categoryPostDetail: (_) => const CategoryPostDetailScreen(),
    genericCategory: (context) => const GenericCategoryScreen(),

    editProfile: (_) => const EditProfileScreen(),
    myPosts: (_) => const MyPostsScreen(),
  };
}
