import 'package:flutter/material.dart';
import 'package:plant_app/views/screens/auth_gate.dart';
import 'package:provider/provider.dart';
import 'package:plant_app/theme/app_theme.dart';
import 'package:plant_app/viewmodels/auth_viewmodel.dart';
import 'package:plant_app/viewmodels/home_viewmodel.dart';
import 'package:plant_app/viewmodels/history_viewmodel.dart';
import 'package:plant_app/viewmodels/profile_viewmodel.dart';
import 'package:plant_app/viewmodels/theme_viewmodel.dart';

void main() {
  runApp(const PlantaCareApp());
}

class PlantaCareApp extends StatelessWidget {
  const PlantaCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => HistoryViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeVM, child) {
          return MaterialApp(
            title: 'PlantaCare AI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeVM.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}
