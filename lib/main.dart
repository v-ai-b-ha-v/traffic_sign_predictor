import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterui/bloc/theme_bloc.dart';
import 'package:flutterui/pages/homepage.dart';
import 'package:flutterui/themes/darkmode.dart';
import 'package:flutterui/themes/lightmode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeBloc(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            home: const HomePage(),
            theme: state is LightTheme ? lightMode : darkMode,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
