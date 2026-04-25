import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';
import 'providers/motivation_provider.dart';
import 'features/motivations/motivation_screen.dart';
import 'features/auth/login_screen.dart'; // Tambahan import login

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MotivationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, theme, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: theme.themeMode,

            // Ganti halaman awal ke LoginScreen
            home: LoginScreen(),

            // Opsional: kalau nanti mau navigasi pakai route
            routes: {
              '/login': (_) => LoginScreen(),
              '/home': (_) => MotivationScreen(),
            },
          );
        },
      ),
    );
  }
}