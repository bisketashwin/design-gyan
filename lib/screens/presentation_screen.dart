// lib/screens/presentation_screen.dart

import 'package:design_gyan/commons/values.dart';
import 'package:design_gyan/models/slide_data.dart';
import 'package:design_gyan/providers/presentation_state.dart';
import 'package:design_gyan/widgets/full_media_slide_view.dart';
import 'package:design_gyan/widgets/progressive_grid_view.dart';
import 'package:design_gyan/widgets/standard_blocks_slide_view.dart';
import 'package:design_gyan/widgets/standard_slide.dart';
import 'package:design_gyan/widgets/view_port_settings_dialogue/widgets/grid_slide_view.dart';
import 'package:design_gyan/widgets/view_port_settings_dialogue/widgets/title_card_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import '../providers/presentation_provider.dart';
import '../widgets/presentation_footer.dart';

class PresentationScreen extends ConsumerStatefulWidget {
  const PresentationScreen({super.key});

  @override
  ConsumerState<PresentationScreen> createState() => _PresentationScreenState();
}

class _PresentationScreenState extends ConsumerState<PresentationScreen> {
  final FocusNode _mainFocusNode = FocusNode();

  @override
  void dispose() {
    _mainFocusNode.dispose();
    super.dispose();
  }

  void _reclaimFocus() {
    if (!_mainFocusNode.hasFocus) {
      _mainFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncPresentationState = ref.watch(presentationProvider);
    final notifier = ref.read(presentationProvider.notifier);

    return asyncPresentationState.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFFB800)),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Text(
            'Error loading presentation: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
      data: (state) {
        if (state.isLoading || state.slides.isEmpty || state.currentSlide == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFFFB800)),
            ),
          );
        }

        final slide = state.currentSlide!;
        final headerSteps = state.headerStepCount;
        final calloutsCount = slide.callouts.length;
        final itemStartOffset = headerSteps + calloutsCount;
        final visibleListItems = (state.visibleStepCount - itemStartOffset).clamp(0, slide.items.length);

        print('slide ${slide.title} type ${slide.type}');

        return KeyboardListener(
          focusNode: _mainFocusNode..requestFocus(),
          onKeyEvent: notifier.handleKeyEvent,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              _reclaimFocus();
              notifier.nextStep();
            },
            child: Scaffold(
              backgroundColor: const Color(0xFF121212), // Ensures screen isn't white/blank if child fails
              body: Stack(
                children: [
                  // Slide Views
                  Positioned.fill(
                    child: _buildSlideView(slide, state, visibleListItems),
                  ),

                  // Left Navigation Button
                  if (state.currentSlideIndex > 0)
                    Positioned(
                      left: 16,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: PointerInterceptor(
                          child: IconButton.filledTonal(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black.withOpacity(0.6),
                              hoverColor: const Color(0xFFFFB800),
                            ),
                            icon: const Icon(Icons.chevron_left, color: Colors.white),
                            onPressed: () {
                              _reclaimFocus();
                              notifier.previousSlideDirect();
                            },
                          ),
                        ),
                      ),
                    ),

                  // Right Navigation Button
                  if (state.currentSlideIndex < state.slides.length - 1)
                    Positioned(
                      right: 16,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: PointerInterceptor(
                          child: IconButton.filledTonal(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black.withOpacity(0.6),
                              hoverColor: const Color(0xFFFFB800),
                            ),
                            icon: const Icon(Icons.chevron_right, color: Colors.white),
                            onPressed: () {
                              _reclaimFocus();
                              notifier.nextSlideDirect();
                            },
                          ),
                        ),
                      ),
                    ),

                  // Footer Controls
                  Positioned(
                    bottom: 30,
                    left: 80,
                    right: 80,
                    child: PointerInterceptor(
                      child: PresentationFooter(
                        currentSlideIndex: state.currentSlideIndex,
                        totalSlides: state.slides.length,
                        isAtSlideEnd: state.isAtSlideEnd,
                        onNext: () {
                          _reclaimFocus();
                          notifier.nextSlideDirect();
                        },
                        onPrevious: () {
                          _reclaimFocus();
                          notifier.previousSlideDirect();
                        },
                        onSelectSlide: (idx) {
                          _reclaimFocus();
                          notifier.goToSlide(idx);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSlideView(SlideData slide, PresentationState state, int visibleListItems) {
    switch (slide.type) {
      case SlideType.fullMedia:
        return FullMediaSlideView(
          key: ValueKey('media_${state.currentSlideIndex}'),
          slide: slide,
          visibleStepCount: state.visibleStepCount,
        );
      case SlideType.grid:
        return GridSlideView(
          key: ValueKey('grid_${state.currentSlideIndex}'),
          slide: slide,
          visibleStepCount: state.visibleStepCount,
        );
      case SlideType.titleCard:
        return TitleCardSlideView(
          key: ValueKey('title_${state.currentSlideIndex}'),
          slide: slide,
          visibleStepCount: state.visibleStepCount,
        );
      case SlideType.progressiveGrid:
        return ProgressiveGridView(
          key: ValueKey('progressive_grid_${state.currentSlideIndex}'),
          slide: slide,
          visibleStepCount: state.visibleStepCount,
        );
      case SlideType.standardBlocks:
        return StandardBlocksSlideView(
          key: ValueKey('standard_blocks_${state.currentSlideIndex}'),
          slide: slide,
          visibleStepCount: state.visibleStepCount,
        );
      case SlideType.standard:
      default:
        return StandardSlideView(
          key: ValueKey('standard_${state.currentSlideIndex}'),
          slide: slide,
          visibleStepCount: state.visibleStepCount,
          visibleListItems: visibleListItems,
        );
    }
  }
}