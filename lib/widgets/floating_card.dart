import 'package:design_gyan/models/slide_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/viewport_setting_provider.dart';
import '../utils/markdown_formatter.dart';

class FloatingCard extends ConsumerStatefulWidget {
  final SlideData slide;
  const FloatingCard({super.key, required this.slide});

  @override
  ConsumerState<FloatingCard> createState() => _FloatingCardState();
}

class _FloatingCardState extends ConsumerState<FloatingCard> {
  bool _isMinimized = false;

  @override
  Widget build(BuildContext context) {
    final viewport = ref.watch(viewportSettingsProvider);
    final baseUiSize = viewport.getBaseUiSize(context);
    final slide = widget.slide;

    return GestureDetector(
      onTap: () {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: (_isMinimized ? 320 : 520) * viewport.unifiedZoom,
        constraints: BoxConstraints(
          maxHeight: (_isMinimized ? 64 : 580) * viewport.unifiedZoom,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 20 * viewport.unifiedZoom,
          vertical: 12 * viewport.unifiedZoom,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF090A0F).withOpacity(0.92),
          borderRadius: BorderRadius.circular(16 * viewport.unifiedZoom),
          border: Border.all(color: Colors.white12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (_isMinimized) ...[
                  Icon(
                    Icons.info_outline,
                    color: const Color(0xFFFFB800),
                    size: baseUiSize * 1.4,
                  ),
                  SizedBox(width: 8 * viewport.unifiedZoom),
                ],
                Expanded(
                  child: Text(
                    slide.title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: baseUiSize * 1.3 * viewport.textScale,
                      fontWeight: FontWeight.w900,
                      letterSpacing: viewport.letterSpacing,
                      color: const Color(0xFFFFB800),
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    _isMinimized ? Icons.open_in_full : Icons.close_fullscreen,
                    color: Colors.white70,
                    size: baseUiSize * 1.4,
                  ),
                  onPressed: () {
                    setState(() {
                      _isMinimized = !_isMinimized;
                    });
                  },
                ),
              ],
            ),
            if (!_isMinimized) ...[
              if (slide.subtitle != null) ...[
                SizedBox(height: 8 * viewport.unifiedZoom),
                Text(
                  slide.subtitle!,
                  style: TextStyle(
                    fontSize: baseUiSize * 1.3 * viewport.textScale,
                    fontStyle: FontStyle.italic,
                    letterSpacing: viewport.letterSpacing,
                    color: const Color(0xFF00F0FF),
                  ),
                ),
              ],
              if (slide.callouts.isNotEmpty) SizedBox(height: 12 * viewport.unifiedZoom),
              ...slide.callouts.map(
                (text) => Padding(
                  padding: EdgeInsets.only(bottom: 10.0 * viewport.unifiedZoom),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: baseUiSize * 1.05 * viewport.textScale,
                      color: const Color(0xFFFFB800),
                      fontStyle: FontStyle.italic,
                      height: viewport.lineHeight,
                      letterSpacing: viewport.letterSpacing,
                    ),
                  ),
                ),
              ),
              if (slide.items.isNotEmpty) ...[
                SizedBox(height: 8 * viewport.unifiedZoom),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: slide.items.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 6.0 * viewport.unifiedZoom),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "⚡ ",
                              style: TextStyle(
                                fontSize: baseUiSize * 1.05 * viewport.textScale,
                                color: const Color(0xFFFFB800),
                              ),
                            ),
                            Expanded(
                              child: RichText(
                                text: MarkdownFormatter.parseInline(
                                  slide.items[index],
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
                      );
                    },
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}