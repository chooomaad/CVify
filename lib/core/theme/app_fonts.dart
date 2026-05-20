import 'package:flutter/material.dart';

/// Local typography without [google_fonts] or runtime network access.
///
/// Uses SF Pro on iOS via [fontFamilyFallback]; Material/Roboto on Android.
class AppFonts {
  AppFonts._();

  static const List<String> fallbackFamilies = [
    'SF Pro',
    'SF Pro Text',
    'SF Pro Display',
    '.AppleSystemUIFont',
    'Roboto',
    'Helvetica Neue',
    'Arial',
    'sans-serif',
  ];

  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamilyFallback: fallbackFamilies,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }
}
