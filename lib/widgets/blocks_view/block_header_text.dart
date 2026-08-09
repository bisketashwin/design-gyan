
import 'package:design_gyan/commons/values.dart';
import 'package:design_gyan/models/slide_data.dart';
import 'package:design_gyan/providers/viewport_setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BlockHeaderText extends ConsumerWidget {
  final Block block;
  const BlockHeaderText({super.key, required this.block});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewport = ref.watch(viewportSettingsProvider);
    final baseUiSize = viewport.getBaseUiSize(context);
    final isTitle = block.role == BlockRole.header;
    return Padding(
      padding: EdgeInsets.only(bottom: (isTitle ? 8 : 24) * viewport.unifiedZoom),
      child: Text(
        isTitle ? (block.text ?? '').toUpperCase() : (block.text ?? ''),
        style: TextStyle(
          fontSize: baseUiSize * (isTitle ? 2.85 : 2) * viewport.textScale,
          fontWeight: isTitle ? FontWeight.w900 : null,
          color: isTitle ? const Color(0xFFFFB800) : const Color(0xFFE7E7E7),
          height: viewport.lineHeight,
          letterSpacing: (isTitle ? 1.5 * viewport.unifiedZoom : 0) + viewport.letterSpacing,
        ),
      ),
    );
  }
}