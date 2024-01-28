import 'package:city_cab/resources/routes/routes_name.dart';
import 'package:city_cab/screens/history_screen/history_screen.dart';
import 'package:city_cab/screens/login_screen/login_screen.dart';
import 'package:city_cab/screens/main_screen/main_screen.dart';
import 'package:city_cab/screens/payment_&_rating_screen/payment_&_rating_screen.dart';
import 'package:city_cab/screens/profile_screen/profile_screen.dart';
import 'package:city_cab/screens/registration_screen/registration_screen.dart';
import 'package:city_cab/screens/search_screen/search_screen.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

class AppRoutes{
  static appRoutes()=>[
    GetPage(
      name: RoutesName.registrationScreen,
      page: () => RegistrationScreen(),
      transitionDuration: const Duration(milliseconds: 250),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: RoutesName.mainScreen,
      page: () => const MainScreen(),
      transitionDuration: const Duration(milliseconds: 250),
      transition: Transition.leftToRight,
    ),

    GetPage(
      name: RoutesName.loginScreen,
      page: () => LoginScreen(),
      transitionDuration: const Duration(milliseconds: 250),
      transition: Transition.leftToRight,
    ),

    GetPage(
      name: RoutesName.searchScreen,
      page: () => const SearchScreen(),
      transitionDuration: const Duration(milliseconds: 250),
      transition: Transition.leftToRight,
    ),

    GetPage(
      name: RoutesName.profileScreen,
      page: () => const ProfileScreen(),
      transitionDuration: const Duration(milliseconds: 250),
      transition: Transition.leftToRight,
    ),

    GetPage(
      name: RoutesName.historyScreen,
      page: () => const HistoryScreen(),
      transitionDuration: const Duration(milliseconds: 250),
      transition: Transition.leftToRight,
    ),
  ];
}