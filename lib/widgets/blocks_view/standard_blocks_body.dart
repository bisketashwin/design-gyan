import 'package:design_gyan/models/slide_data.dart';
import 'package:design_gyan/widgets/animators/step_animator.dart';
import 'package:design_gyan/widgets/blocks_view/block_view.dart';
import 'package:flutter/material.dart';

class StandardBlocksBody extends StatefulWidget {
  final List<Block> blocks;
  final int visibleStepCount;

  const StandardBlocksBody({
    super.key,
    required this.blocks,
    required this.visibleStepCount,
  });

  @override
  State<StandardBlocksBody> createState() => _StandardBlocksBodyState();
}

class _StandardBlocksBodyState extends State<StandardBlocksBody> {
  final ScrollController _scrollController = ScrollController();

  late List<GlobalKey> _keys;

  @override
  void initState() {
    super.initState();

    _keys = List.generate(
      widget.blocks.length,
      (_) => GlobalKey(),
    );
  }

  @override
  void didUpdateWidget(covariant StandardBlocksBody oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.blocks.length != oldWidget.blocks.length) {
      _keys = List.generate(
        widget.blocks.length,
        (_) => GlobalKey(),
      );
    }

    if (widget.visibleStepCount > oldWidget.visibleStepCount) {
      _scrollToLatest();
    }
  }

  void _scrollToLatest() {
    int target = -1;

    for (var i = 0; i < widget.blocks.length; i++) {
      if (widget.blocks[i].revealStep <= widget.visibleStepCount) {
        target = i;
      }
    }

    if (target < 0) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final context = _keys[target].currentContext;

      if (context == null) return;

      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        alignment: 0.9,
        alignmentPolicy:
            ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // REMOVED the redundant Expanded wrapper here since the parent Row already handles flex bounds.
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      // ADDED: Bottom padding to give clearance for the final list item
      padding: const EdgeInsets.only(bottom: 100.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < widget.blocks.length; index++)
            _buildBlock(index),
        ],
      ),
    );
  }

  Widget _buildBlock(int index) {
    final block = widget.blocks[index];

    final isVisible =
        widget.visibleStepCount >= block.revealStep;

    return KeyedSubtree(
      key: _keys[index],
      child: StepAnimator(
        isVisible: isVisible,
        child: BlockView(
          block: block,
          isVisible: isVisible,
        ),
      ),
    );
  }
}