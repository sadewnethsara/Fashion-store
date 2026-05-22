import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_providers.dart';
import 'core/theme.dart';
import 'controllers/auth_controller.dart';
import 'core/theme_controller.dart';
import 'firebase_options.dart';
import 'views/auth/login_screen.dart';
import 'views/admin/admin_home_screen.dart';
import 'views/main_navigation.dart';
import 'widgets/cart_sync.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: createAppProviders(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return MaterialApp(
          title: 'BH Cloths',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          debugShowCheckedModeBanner: false,
          home: Consumer<AuthController>(
            builder: (context, authController, _) {
              if (!authController.isReady) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (!authController.isAuthenticated) {
                return const LoginScreen();
              }
              if (authController.isAdmin) {
                return const AdminHomeScreen();
              }
              return const CartSync(child: MainNavigation());
            },
          ),
        );
      },
    );
  }
}
