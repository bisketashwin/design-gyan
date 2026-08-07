import 'package:design_gyan/commons/helpers.dart';
import 'package:design_gyan/models/progressive_grid_models.dart';
import 'package:design_gyan/models/slide_data.dart';
import 'package:design_gyan/providers/viewport_setting_provider.dart';
import 'package:design_gyan/utils/markdown_formatter.dart';
import 'package:design_gyan/widgets/slide_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProgressiveGridView extends ConsumerWidget {
  final SlideData slide;
  final int visibleStepCount;

  const ProgressiveGridView({
    super.key,
    required this.slide,
    required this.visibleStepCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewport = ref.watch(viewportSettingsProvider);
    final gridData = slide.progressiveGridData;

    if (gridData == null) {
      return const SizedBox.shrink();
    }

    final horizontalPadding = 80.0 * viewport.unifiedZoom;
    final verticalPadding = 50.0 * viewport.unifiedZoom;

    return Stack(
      children: [
        const BackgroundGradient(),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header showing correctly via SlideHeader
              SlideHeader(
                title: slide.title,
                subtitle: slide.subtitle,
                visibleStepCount: visibleStepCount,
              ),
              SizedBox(height: 28 * viewport.unifiedZoom),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final totalWidth = constraints.maxWidth;
                      final columns = gridData.columns.clamp(1, 12);
                      const double spacing = 16.0;

                      // 4. Width option (Calculated percentage per column minus gaps)
                      final cardWidth =
                          (totalWidth - ((columns - 1) * spacing)) / columns;

                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: gridData.cards.map((card) {
                          return SizedBox(
                            width: cardWidth,
                            // 3. Card wraps height around content naturally
                            child: ProgressiveCardWidget(
                              card: card,
                              currentStep: visibleStepCount,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 80 * viewport.unifiedZoom), // Footer clearance
            ],
          ),
        ),
      ],
    );
  }
}

class ProgressiveCardWidget extends ConsumerWidget {
  final CardPointNode card;
  final int currentStep;

  const ProgressiveCardWidget({
    super.key,
    required this.card,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewport = ref.watch(viewportSettingsProvider);
    final baseUiSize = viewport.getBaseUiSize(context);
    final bool isCardVisible = currentStep >= card.baseRevealStep;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      opacity: isCardVisible ? 1.0 : 0.0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        offset: isCardVisible ? Offset.zero : const Offset(0, 0.05),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF121620),
            borderRadius: BorderRadius.circular(12 * viewport.unifiedZoom),
            border: Border.all(color: Colors.white12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0 * viewport.unifiedZoom),
            child: Column(
              mainAxisSize: MainAxisSize.min, // 3. Wrap height content
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (card.imageUrl != null) ...[
                  // 5. Enforce aspect ratio and visibility logic
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8 * viewport.unifiedZoom),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.asset(
                        card.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF1A1F2C),
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white24,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12 * viewport.unifiedZoom),
                ],
                // 2. Inherit font sizes and scaling from Viewport
                Text(
                  card.title.toUpperCase(),
                  style: TextStyle(
                    fontSize: baseUiSize * 1.25 * viewport.textScale,
                    fontWeight: FontWeight.bold,
                    letterSpacing: viewport.letterSpacing,
                    color: const Color(0xFFFFB800),
                  ),
                ),
                if (card.subPoints.isNotEmpty) ...[
                  SizedBox(height: 10 * viewport.unifiedZoom),
                  const Divider(color: Colors.white12, height: 1),
                  SizedBox(height: 10 * viewport.unifiedZoom),
                  ...card.subPoints.map(
                    (point) => _SubPointItem(
                      point: point,
                      isVisible: currentStep >= point.revealStep,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubPointItem extends ConsumerWidget {
  final SubPointData point;
  final bool isVisible;

  const _SubPointItem({
    required this.point,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewport = ref.watch(viewportSettingsProvider);
    final baseUiSize = viewport.getBaseUiSize(context);

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isVisible ? 1.0 : 0.0,
        child: isVisible
            ? Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 6.0 * viewport.unifiedZoom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (point.hasImage) ...[
                      // 5. Enforce ratio & max-bounds on inline media
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6 * viewport.unifiedZoom),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.asset(
                            point.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFF1A1F2C),
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.white24,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (point.hasText) SizedBox(height: 6 * viewport.unifiedZoom),
                    ],
                    if (point.hasText)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "⚡ ",
                            style: TextStyle(
                              fontSize: baseUiSize * 1.0 * viewport.textScale,
                              color: const Color(0xFFFFB800),
                            ),
                          ),
                          Expanded(
                            child: RichText(
                              text: MarkdownFormatter.parseInline(
                                point.text!,
                                TextStyle(
                                  fontSize: baseUiSize * 1.05 * viewport.textScale,
                                  height: viewport.lineHeight,
                                  letterSpacing: viewport.letterSpacing,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}