// lib/widgets/slide_content_list.dart

import 'package:flutter/material.dart';
import '../utils/markdown_formatter.dart';
import 'animators/step_animator.dart';

class SlideContentList extends StatefulWidget {
  final List<String> items;
  final int visibleItemCount;

  const SlideContentList({
    super.key,
    required this.items,
    required this.visibleItemCount,
  });

  @override
  State<SlideContentList> createState() => _SlideContentListState();
}

class _SlideContentListState extends State<SlideContentList> {
  final ScrollController _scrollController = ScrollController();
  late List<GlobalKey> _itemKeys;

  @override
  void initState() {
    super.initState();
    _itemKeys = List.generate(widget.items.length, (_) => GlobalKey());
  }

  @override
  void didUpdateWidget(covariant SlideContentList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.items.length != oldWidget.items.length) {
      _itemKeys = List.generate(widget.items.length, (_) => GlobalKey());
    }

    // When stepping forward to reveal an item
    if (widget.visibleItemCount > oldWidget.visibleItemCount &&
        widget.visibleItemCount > 0) {
      _scrollToItem(widget.visibleItemCount - 1);
    }
  }

  void _scrollToItem(int index) {
    if (index < 0 || index >= _itemKeys.length) return;

    // Post-frame callback ensures the animation step state has been processed by Flutter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keyContext = _itemKeys[index].currentContext;
      if (keyContext != null) {
        Scrollable.ensureVisible(
          keyContext,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          alignment: 0.9, // Positions the active item near the bottom of the viewport
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final isVisible = index < widget.visibleItemCount;

          return KeyedSubtree(
            key: _itemKeys[index],
            child: StepAnimator(
              isVisible: isVisible,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "⚡ ",
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFFFFB800),
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        text: MarkdownFormatter.parseInline(
                          widget.items[index],
                          TextStyle(
                            fontSize: 21,
                            height: 1.5,
                            color: isVisible ? Colors.white70 : Colors.white24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}