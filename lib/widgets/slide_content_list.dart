import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/viewport_setting_provider.dart';
import '../utils/markdown_formatter.dart';
import 'animators/step_animator.dart';

class SlideContentList extends ConsumerStatefulWidget {
  final List<String> items;
  final int visibleItemCount;

  const SlideContentList({
    super.key,
    required this.items,
    required this.visibleItemCount,
  });

  @override
  ConsumerState<SlideContentList> createState() => _SlideContentListState();
}

class _SlideContentListState extends ConsumerState<SlideContentList> {
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
    if (widget.visibleItemCount > oldWidget.visibleItemCount &&
        widget.visibleItemCount > 0) {
      _scrollToItem(widget.visibleItemCount - 1);
    }
  }

  void _scrollToItem(int index) {
    if (index < 0 || index >= _itemKeys.length) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keyContext = _itemKeys[index].currentContext;
      if (keyContext != null) {
        Scrollable.ensureVisible(
          keyContext,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          alignment: 0.9,
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
    final viewport = ref.watch(viewportSettingsProvider);
    final baseUiSize = viewport.getBaseUiSize(context);

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
                padding: EdgeInsets.symmetric(vertical: 10.0 * viewport.unifiedZoom),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "⚡ ",
                      style: TextStyle(
                        fontSize: baseUiSize * 1.4 * viewport.textScale,
                        color: const Color(0xFFFFB800),
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        text: MarkdownFormatter.parseInline(
                          widget.items[index],
                          TextStyle(
                            fontSize: baseUiSize * 1.5 * viewport.textScale,
                            height: viewport.lineHeight,
                            letterSpacing: viewport.letterSpacing,
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