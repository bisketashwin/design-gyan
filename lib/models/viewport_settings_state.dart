import 'package:flutter/material.dart';

class ViewportSettingsState {
  final double unifiedZoom;
  final double textScale;
  final double mediaScale;
  final double lineHeight;
  final double letterSpacing;

  const ViewportSettingsState({
    this.unifiedZoom = 1.0,
    this.textScale = 1.0,
    this.mediaScale = 1.0,
    this.lineHeight = 1.4,
    this.letterSpacing = 0.0,
  });

  // 1. Form-Factor Breakpoint Base UI Font Size (For Footer / Navigation Chrome)
  double getUiBaseFontSize(double screenWidth) {
    if (screenWidth < 600) return 11.0; // Mobile
    if (screenWidth < 1200) return 12.5; // Tablet / Laptop
    return 14.0; // Desktop / 4K
  }

  // 2. Resolved UI Chrome Font Size
  // Ignores slide textScale / unifiedZoom, but respects system accessibility scaling
  double getBaseUiSize(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final systemTextScaler = MediaQuery.textScalerOf(context);
    final baseSize = getUiBaseFontSize(screenWidth);

    // Scale base UI font size via system OS accessibility settings only
    return systemTextScaler.scale(baseSize);
  }

  // 3. Resolved Slide Content Scaler
  // Combines system OS accessibility + form factor baseline + user sliders
  TextScaler getContentTextScaler(BuildContext context) {
    final systemTextScaler = MediaQuery.textScalerOf(context);
    final combinedUserScale = (unifiedZoom * textScale).clamp(0.5, 2.2);

    // Multiply user preferences with system accessibility scaler
    return TextScaler.linear(
      systemTextScaler.scale(16) / 16 * combinedUserScale,
    );
  }

  ViewportSettingsState copyWith({
    double? unifiedZoom,
    double? textScale,
    double? mediaScale,
    double? lineHeight,
    double? letterSpacing,
  }) {
    return ViewportSettingsState(
      unifiedZoom: unifiedZoom ?? this.unifiedZoom,
      textScale: textScale ?? this.textScale,
      mediaScale: mediaScale ?? this.mediaScale,
      lineHeight: lineHeight ?? this.lineHeight,
      letterSpacing: letterSpacing ?? this.letterSpacing,
    );
  }
}
