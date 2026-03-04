import 'package:flutter/material.dart';

import '../../screens/add_meal/add_meal_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/dishes/create_dish_screen.dart';
import '../../screens/foods/create_food_screen.dart';
import '../../screens/home/home_shell.dart';
import '../../screens/profile/edit_profile_screen.dart';
import '../../screens/splash/splash_screen.dart';
import '../navigation/app_routes.dart';

/// Single place to build routes.
///
/// This keeps navigation consistent and scalable as the app grows.
class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _fade(const SplashScreen());
      case AppRoutes.login:
        return _slide(const LoginScreen());
      case AppRoutes.register:
        return _slide(const RegisterScreen());
      case AppRoutes.home:
        return _slide(const HomeShell());
      case AppRoutes.addMeal:
        return _bottomSheetLike(const AddMealScreen());
      case AppRoutes.createDish:
        return _slide(const CreateDishScreen());
      case AppRoutes.createFood:
        return _slide(const CreateFoodScreen());
      case AppRoutes.editProfile:
        return _slide(const EditProfileScreen());
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Ruta no encontrada')),
          ),
        );
    }
  }

  static PageRoute<T> _fade<T>(Widget child) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => child,
      transitionsBuilder: (_, animation, __, child) => FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  static PageRoute<T> _slide<T>(Widget child) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => child,
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween<Offset>(begin: const Offset(0.0, 0.06), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  static PageRoute<T> _bottomSheetLike<T>(Widget child) {
    return PageRouteBuilder<T>(
      opaque: false,
      barrierColor: Colors.black.withOpacity(0.35),
      pageBuilder: (_, __, ___) => child,
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}

