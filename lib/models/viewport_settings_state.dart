import 'package:flutter/widgets.dart';

class ViewportSettingsState {
  final double unifiedZoom;
  final double textScale;
  final double mediaScale;
  final double lineHeight;
  final double letterSpacing;

  final String? activePresetKey; // Null if no preset saved yet
  final Map<String, ViewportSettingsState> savedPresets;

  const ViewportSettingsState({
    this.unifiedZoom = 1.0,
    this.textScale = 1.0,
    this.mediaScale = 1.0,
    this.lineHeight = 1.4,
    this.letterSpacing = 0.0,
    this.activePresetKey,
    this.savedPresets = const {},
  });

  double _getUiBaseFontSize(double screenWidth) {
    if (screenWidth < 600) return 11.0;
    if (screenWidth < 1200) return 12.5;
    return 14.0;
  }

  double getBaseUiSize(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final systemTextScaler = MediaQuery.textScalerOf(context);
    final baseSize = _getUiBaseFontSize(screenWidth);
    return systemTextScaler.scale(baseSize);
  }

  static const ViewportSettingsState factoryDefaults = ViewportSettingsState(
    unifiedZoom: 1.0,
    textScale: 1.0,
    mediaScale: 1.0,
    lineHeight: 1.4,
    letterSpacing: 0.0,
  );

  bool hasDeltaFrom(ViewportSettingsState other) {
    return (unifiedZoom - other.unifiedZoom).abs() > 0.001 ||
        (textScale - other.textScale).abs() > 0.001 ||
        (mediaScale - other.mediaScale).abs() > 0.001 ||
        (lineHeight - other.lineHeight).abs() > 0.001 ||
        (letterSpacing - other.letterSpacing).abs() > 0.001;
  }

  Map<String, dynamic> toJson() => {
        'unifiedZoom': unifiedZoom,
        'textScale': textScale,
        'mediaScale': mediaScale,
        'lineHeight': lineHeight,
        'letterSpacing': letterSpacing,
      };

  factory ViewportSettingsState.fromJson(Map<String, dynamic> json) {
    return ViewportSettingsState(
      unifiedZoom: (json['unifiedZoom'] as num?)?.toDouble() ?? 1.0,
      textScale: (json['textScale'] as num?)?.toDouble() ?? 1.0,
      mediaScale: (json['mediaScale'] as num?)?.toDouble() ?? 1.0,
      lineHeight: (json['lineHeight'] as num?)?.toDouble() ?? 1.4,
      letterSpacing: (json['letterSpacing'] as num?)?.toDouble() ?? 0.0,
    );
  }

  double get baseValueMediaScale => mediaScale;

  ViewportSettingsState copyWith({
    double? unifiedZoom,
    double? textScale,
    double? mediaScale,
    double? lineHeight,
    double? letterSpacing,
    String? activePresetKey,
    bool forceNullActivePreset = false,
    Map<String, ViewportSettingsState>? savedPresets,
  }) {
    return ViewportSettingsState(
      unifiedZoom: unifiedZoom ?? this.unifiedZoom,
      textScale: textScale ?? this.textScale,
      mediaScale: mediaScale ?? this.mediaScale,
      lineHeight: lineHeight ?? this.lineHeight,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      activePresetKey: forceNullActivePreset
          ? null
          : (activePresetKey ?? this.activePresetKey),
      savedPresets: savedPresets ?? this.savedPresets,
    );
  }
}