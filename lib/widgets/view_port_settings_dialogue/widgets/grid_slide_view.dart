import 'package:design_gyan/commons/helpers.dart';
import 'package:design_gyan/commons/values.dart';
import 'package:design_gyan/models/slide_data.dart';
import 'package:design_gyan/widgets/animators/step_animator.dart';
import 'package:design_gyan/widgets/slide_header.dart';
import 'package:flutter/material.dart';

class GridSlideView extends StatelessWidget {
  final SlideData slide;
  final int visibleStepCount;

  const GridSlideView({
    super.key,
    required this.slide,
    required this.visibleStepCount,
  });

  @override
  Widget build(BuildContext context) {
    final headerSteps = 1 + (slide.subtitle != null ? 1 : 0);
    final visibleGridCount = (visibleStepCount - headerSteps).clamp(0, slide.gridItems.length);

    return Stack(
      children: [
        const BackgroundGradient(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 80.0, vertical: 50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SlideHeader(
                title: slide.title,
                subtitle: slide.subtitle,
                visibleStepCount: visibleStepCount,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _buildGrid(visibleGridCount),
              ),
              const SizedBox(height: 80), // Footer clearance
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(int visibleGridCount) {
    final isColumn = slide.gridDirection == GridDirection.column;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalItems = slide.gridItems.length;
        if (totalItems == 0) return const SizedBox.shrink();

        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;
        const double spacing = 16.0;

        if (isColumn) {
          final crossAxisCount = slide.gridCount.clamp(1, 12);
          // Calculate total rows needed (e.g., 6 items with 3 columns = 2 rows)
          final totalRows = (totalItems / crossAxisCount).ceil().clamp(1, 100);

          // Calculate maximum allowed dimensions per card to fit viewport exactly
          final cardWidth = (availableWidth - ((crossAxisCount - 1) * spacing)) / crossAxisCount;
          final cardHeight = (availableHeight - ((totalRows - 1) * spacing)) / totalRows;

          // Flutter Grid childAspectRatio = width / height
          final aspectRatio = cardWidth / cardHeight;

          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: aspectRatio,
            ),
            itemCount: slide.gridItems.length,
            itemBuilder: (context, index) {
              final isVisible = index < visibleGridCount;
              return StepAnimator(
                isVisible: isVisible,
                child: _GridCard(item: slide.gridItems[index]),
              );
            },
          );
        } else {
          // Row direction logic
          final rowCount = slide.gridCount.clamp(1, 12);
          final totalColumns = (totalItems / rowCount).ceil().clamp(1, 100);

          final cardHeight = (availableHeight - ((rowCount - 1) * spacing)) / rowCount;
          final cardWidth = (availableWidth - ((totalColumns - 1) * spacing)) / totalColumns;

          final aspectRatio = cardWidth / cardHeight;

          return GridView.builder(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: rowCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: aspectRatio,
            ),
            itemCount: slide.gridItems.length,
            itemBuilder: (context, index) {
              final isVisible = index < visibleGridCount;
              return StepAnimator(
                isVisible: isVisible,
                child: _GridCard(item: slide.gridItems[index]),
              );
            },
          );
        }
      },
    );
  }
}

class _GridCard extends StatelessWidget {
  final GridItemData item;

  const _GridCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isNetworkUrl = item.imageUrl.startsWith('http://') || item.imageUrl.startsWith('https://');

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121620),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 1. Image View
          Positioned.fill(
            child: isNetworkUrl
                ? Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  )
                : Image.asset(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  ),
          ),

          // 2. Bottom Label Banner
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                border: const Border(
                  top: BorderSide(color: Color(0xFFFFB800), width: 2),
                ),
              ),
              child: Text(
                item.label.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF1A1F2C),
      child: const Center(
        child: Icon(Icons.sports_esports, color: Colors.white24, size: 48),
      ),
    );
  }
}