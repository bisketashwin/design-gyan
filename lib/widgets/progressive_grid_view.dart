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
    final effectiveTitle = slide.title.trim().isNotEmpty 
        ? slide.title 
        : (gridData.title.isNotEmpty ? gridData.title : 'UNTITLED');

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
              // 1. Header
              SlideHeader(
                title: effectiveTitle,
                subtitle: slide.subtitle,
                visibleStepCount: visibleStepCount,
              ),  
              SizedBox(height: 28 * viewport.unifiedZoom),

              // 2. Main Content Area
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final totalWidth = constraints.maxWidth;
                    final columns = gridData.columns.clamp(1, 12);
                    const double spacing = 16.0;

                    final double computedFallbackWidth =
                        (totalWidth - ((columns - 1) * spacing)) / columns;

                    final double cardWidth = gridData.cardWidthPercent != null
                        ? totalWidth * gridData.cardWidthPercent!
                        : computedFallbackWidth;

                    return Align(
                      alignment: Alignment.topLeft,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          alignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          children: gridData.cards.map((card) {
                            return SizedBox(
                              width: cardWidth,
                              child: ProgressiveCardWidget(
                                card: card,
                                currentStep: visibleStepCount,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 80 * viewport.unifiedZoom),
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
    final bool hasHeaderImage =
        card.imageUrl != null && card.imageUrl!.trim().isNotEmpty;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      opacity: isCardVisible ? 1.0 : 0.0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        offset: isCardVisible ? Offset.zero : const Offset(0, 0.05),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF121620),
            borderRadius: BorderRadius.circular(12 * viewport.unifiedZoom),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasHeaderImage) ...[
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(8 * viewport.unifiedZoom),
                    child: AspectRatio(
                      aspectRatio: card.aspectRatio,
                      child: Image.asset(
                        card.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
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
                Text(
                  card.title.toUpperCase(),
                  textAlign: TextAlign.left,
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
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(6 * viewport.unifiedZoom),
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
                      if (point.hasText)
                        SizedBox(height: 6 * viewport.unifiedZoom),
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
                                  fontSize:
                                      baseUiSize * 1.05 * viewport.textScale,
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