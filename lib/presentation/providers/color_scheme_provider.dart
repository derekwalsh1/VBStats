import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ColorSchemeType {
  boldStadium,
  neonCourt,
  classicSports,
  volleyballArena,
}

class ColorSchemeData {
  final String name;
  final Color grayColor;
  final Color greenColor;
  final Color redColor;
  final Color performanceColor;
  final Color grayTextColor;
  final Color greenTextColor;
  final Color redTextColor;
  final Color performanceTextColor;

  const ColorSchemeData({
    required this.name,
    required this.grayColor,
    required this.greenColor,
    required this.redColor,
    required this.performanceColor,
    required this.grayTextColor,
    required this.greenTextColor,
    required this.redTextColor,
    required this.performanceTextColor,
  });
}

class ColorSchemeNotifier extends StateNotifier<ColorSchemeType> {
  ColorSchemeNotifier() : super(ColorSchemeType.boldStadium);

  void setColorScheme(ColorSchemeType scheme) {
    state = scheme;
  }

  ColorSchemeData get currentScheme {
    switch (state) {
      case ColorSchemeType.boldStadium:
        return ColorSchemeData(
          name: 'Bold Stadium',
          grayColor: Colors.grey.shade800,
          greenColor: Colors.lightGreen.shade400,
          redColor: Colors.red.shade600,
          performanceColor: Colors.blue.shade600,
          grayTextColor: Colors.white,
          greenTextColor: Colors.black,
          redTextColor: Colors.white,
          performanceTextColor: Colors.white,
        );
      case ColorSchemeType.neonCourt:
        return ColorSchemeData(
          name: 'Neon Court',
          grayColor: Colors.grey.shade900,
          greenColor: Colors.green.shade500,
          redColor: Colors.pink.shade600,
          performanceColor: Colors.cyan.shade500,
          grayTextColor: Colors.white,
          greenTextColor: Colors.black,
          redTextColor: Colors.white,
          performanceTextColor: Colors.black,
        );
      case ColorSchemeType.classicSports:
        return ColorSchemeData(
          name: 'Classic Sports',
          grayColor: Colors.blueGrey.shade400,
          greenColor: Colors.green.shade700,
          redColor: Colors.red.shade700,
          performanceColor: Colors.indigo.shade600,
          grayTextColor: Colors.white,
          greenTextColor: Colors.white,
          redTextColor: Colors.white,
          performanceTextColor: Colors.white,
        );
      case ColorSchemeType.volleyballArena:
        return ColorSchemeData(
          name: 'Volleyball Arena',
          grayColor: Colors.blueGrey.shade800,
          greenColor: Colors.green.shade600,
          redColor: Colors.red.shade700,
          performanceColor: Colors.orange.shade600,
          grayTextColor: Colors.white,
          greenTextColor: Colors.white,
          redTextColor: Colors.white,
          performanceTextColor: Colors.white,
        );
    }
  }
}

final colorSchemeProvider = StateNotifierProvider<ColorSchemeNotifier, ColorSchemeType>((ref) {
  return ColorSchemeNotifier();
});
