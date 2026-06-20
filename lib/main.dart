import 'package:flutter/material.dart';

import 'game/game_controller.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/now_playing_indicator.dart';

void main() {
  runApp(const SpaceMissionArchitectApp());
}

class SpaceMissionArchitectApp extends StatefulWidget {
  const SpaceMissionArchitectApp({super.key});

  @override
  State<SpaceMissionArchitectApp> createState() => _SpaceMissionArchitectAppState();
}

class _SpaceMissionArchitectAppState extends State<SpaceMissionArchitectApp> {
  final GameController _controller = GameController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Space Mission Architect',
      theme: AppTheme.darkControlCenterTheme,
      builder: (BuildContext context, Widget? child) =>
          NowPlayingIndicator(child: child ?? const SizedBox.shrink()),
      home: HomeScreen(controller: _controller),
    );
  }
}
