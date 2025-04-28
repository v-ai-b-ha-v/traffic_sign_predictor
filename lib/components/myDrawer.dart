import 'package:fancy_switch/fancy_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterui/bloc/theme_bloc.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      child: Center(
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  Text(context.read<ThemeBloc>().state is!  DarkTheme?"Light Mode ☀️":"Dark Mode 🌙",style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30
                  ),),
                  SizedBox(height: 20,),
                  FancySwitch(
                    value: context.read<ThemeBloc>().state is DarkTheme,
                    onChanged: (_) {
                      context.read<ThemeBloc>().add(ToggleTheme());
                    },
                    height: 25,
                    activeModeBackgroundImage: 'assets/dark.jpg',
                    inactiveModeBackgroundImage: 'assets/light.jpg',
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
