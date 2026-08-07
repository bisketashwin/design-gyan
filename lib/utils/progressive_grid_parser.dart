import 'package:design_gyan/models/progressive_grid_models.dart';


class ProgressiveGridParser {
  const ProgressiveGridParser();
   ProgressiveGridData parse(String markdown) {
    final lines = markdown.split('\n');
    
    String mainTitle = '';
    int columns = 3; // Default grid column count
    
    // Config header extraction (e.g. <!-- type: progressive-grid:3 -->)
    final typeMatch = RegExp(r'<!--\s*type:\s*progressive-grid:(\d+)\s*-->').firstMatch(markdown);
    if (typeMatch != null) {
      columns = int.tryParse(typeMatch.group(1) ?? '3') ?? 3;
    }

    final cardRawBlocks = <String>[];
    StringBuffer? currentBlock;

    for (var line in lines) {
      final trimmed = line.trim();
      
      if (trimmed.startsWith('# ') && mainTitle.isEmpty) {
        mainTitle = trimmed.substring(2).trim();
        continue;
      }

      if (trimmed == '<!-- card -->') {
        if (currentBlock != null) {
          cardRawBlocks.add(currentBlock.toString());
        }
        currentBlock = StringBuffer();
        continue;
      }

      if (currentBlock != null) {
        currentBlock.writeln(line);
      }
    }

    if (currentBlock != null) {
      cardRawBlocks.add(currentBlock.toString());
    }

    final cardCount = cardRawBlocks.length;
    final List<CardPointNode> cards = [];
    int maxCalculatedStep = cardCount;

    // Parse each card and assign progressive step indices
    for (int i = 0; i < cardCount; i++) {
      final cardIndex = i + 1; // 1-based index for step order
      final block = cardRawBlocks[i];
      final blockLines = block.split('\n');

      String title = '';
      String? headerImage;
      final List<SubPointData> subPoints = [];

      int currentLocalStepOffset = 0;

      for (var rawLine in blockLines) {
        final line = rawLine.trim();
        if (line.isEmpty) continue;

        // Image match: ![alt](url)
        final imgMatch = RegExp(r'!\[.*?\]\((.*?)\)').firstMatch(line);
        // Header match: ### Title
        final headerMatch = RegExp(r'^###\s+(.+)').firstMatch(line);
        // Step directive match: <!-- step: +N --> or <!-- step: N -->
        final stepMatch = RegExp(r'<!--\s*step:\s*([+\d]+)\s*-->').firstMatch(line);

        if (stepMatch != null) {
          final stepVal = stepMatch.group(1)!;
          if (stepVal.startsWith('+')) {
            currentLocalStepOffset = int.parse(stepVal.substring(1));
          } else {
            // If absolute number is provided directly
            currentLocalStepOffset = int.parse(stepVal) - 1;
          }
          continue;
        }

        if (headerMatch != null) {
          title = headerMatch.group(1)!.trim();
          continue;
        }

        if (imgMatch != null && currentLocalStepOffset == 0 && headerImage == null) {
          headerImage = imgMatch.group(1);
          continue;
        }

        // Sub-points extraction (bullet points or standard lines under relative step)
        if (currentLocalStepOffset > 0) {
          final cleanLine = line.replaceAll(RegExp(r'^[\*\-\+]\s+'), '');
          final subImgMatch = RegExp(r'!\[.*?\]\((.*?)\)').firstMatch(cleanLine);
          
          String? subImg = subImgMatch?.group(1);
          String subText = cleanLine.replaceAll(RegExp(r'!\[.*?\]\((.*?)\)'), '').trim();

          // Compute absolute global step using round-robin distribution:
          // Absolute Step = Card_Index + (Local_Offset * Total_Cards)
          final absoluteStep = cardIndex + (currentLocalStepOffset * cardCount);
          if (absoluteStep > maxCalculatedStep) {
            maxCalculatedStep = absoluteStep;
          }

          subPoints.add(SubPointData(
            text: subText.isNotEmpty ? subText : null,
            imageUrl: subImg,
            revealStep: absoluteStep,
          ));
        }
      }

      cards.add(CardPointNode(
        title: title,
        imageUrl: headerImage,
        baseRevealStep: cardIndex, // Card headers reveal in sequence 1..N
        subPoints: subPoints,
      ));
    }

    return ProgressiveGridData(
      title: mainTitle,
      columns: columns,
      cards: cards,
      maxSteps: maxCalculatedStep,
    );
  }
}