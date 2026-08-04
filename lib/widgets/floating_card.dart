import 'package:design_gyan/models/slide_data.dart';
import 'package:flutter/material.dart';

import '../utils/markdown_formatter.dart';
class FloatingCard extends StatefulWidget {
  final SlideData slide;

  const FloatingCard({super.key, required this.slide});

  @override
  State<FloatingCard> createState() => _FloatingCardState();
}

class _FloatingCardState extends State<FloatingCard> {
  bool _isMinimized = false;

  @override
  Widget build(BuildContext context) {
    final slide = widget.slide;

    return GestureDetector(
      onTap: () {}, // Blocks tap bubbling to presentation tap-handler
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: _isMinimized ? 320 : 520,
        constraints: BoxConstraints(maxHeight: _isMinimized ? 64 : 580),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF090A0F).withOpacity(0.92),
          borderRadius: BorderRadius.circular(16),
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
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFFFFB800),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    slide.title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFFB800),
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    _isMinimized ? Icons.open_in_full : Icons.close_fullscreen,
                    color: Colors.white70,
                    size: 20,
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
                const SizedBox(height: 8),
                Text(
                  slide.subtitle!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF00F0FF),
                  ),
                ),
              ],
              if (slide.callouts.isNotEmpty) const SizedBox(height: 12),
              ...slide.callouts.map(
                (text) => Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFFFFB800),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
              if (slide.items.isNotEmpty) ...[
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: slide.items.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("⚡ ", style: TextStyle(color: Color(0xFFFFB800))),
                            Expanded(
                              child: RichText(
                                text: MarkdownFormatter.parseInline(
                                  slide.items[index],
                                  const TextStyle(
                                    fontSize: 15,
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