import 'package:flutter/material.dart';
import '../models/set_models.dart';
import '../theme/app_theme.dart';
import '../widgets/playing_card_widget.dart';

/// Figma Frame 04: '04  세트 상세 · 카드 집중' (SetDetailScreen, 393x852).
class SetDetailScreen extends StatefulWidget {
  final DetectionResultData result;
  final int initialSetIndex;
  final VoidCallback onBack;
  final VoidCallback onDone;

  const SetDetailScreen({
    super.key,
    required this.result,
    this.initialSetIndex = 0,
    required this.onBack,
    required this.onDone,
  });

  @override
  State<SetDetailScreen> createState() => _SetDetailScreenState();
}

class _SetDetailScreenState extends State<SetDetailScreen> {
  late int _currentIndex;
  bool _twoCardHintOnly = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialSetIndex.clamp(
      0,
      (widget.result.sets.length - 1).clamp(0, 99),
    );
  }

  void _prevSet() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  void _nextSet() {
    if (_currentIndex < widget.result.sets.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sets = widget.result.sets;
    final activeSet = sets[_currentIndex];
    final activeColor = SetColors.setColorForIndex(_currentIndex);
    final activeTint = SetColors.setTintForIndex(_currentIndex);

    // When '2장만 힌트 보기' is ON, only highlight the first 2 cards of the SET
    final visibleIndices = _twoCardHintOnly
        ? activeSet.indices.take(2).toSet()
        : activeSet.indices.toSet();

    return Scaffold(
      backgroundColor: SetColors.bgSlate900,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top section with padding
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 12.0,
                ),
                child: Column(
                  children: [
                    // Detail navigation (345x44): Back icon | '세트 상세' | '완료'
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SetIconButton(
                          icon: Icons.chevron_left,
                          tooltip: '뒤로 가기',
                          onPressed: widget.onBack,
                        ),
                        const Text(
                          '세트 상세',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: SetColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: widget.onDone,
                          child: const Text(
                            '완료',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: SetColors.cyanAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Focused set instruction
                    Text(
                      _twoCardHintOnly
                          ? '힌트 2장과 세트를 이루는 나머지 1장을 찾아보세요'
                          : '강조된 3장의 카드를 함께 확인해보세요',
                      style: const TextStyle(
                        fontSize: 12,
                        color: SetColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Interactive swipeable tabletop focused on active SET (dimming inactive cards)
                    Expanded(
                      child: GestureDetector(
                        onHorizontalDragEnd: (details) {
                          if ((details.primaryVelocity ?? 0) < -150) {
                            _nextSet();
                          } else if ((details.primaryVelocity ?? 0) > 150) {
                            _prevSet();
                          }
                        },
                        child: TabletopBoardWidget(
                          cards: widget.result.cards,
                          activeSets: _twoCardHintOnly ? const [] : [activeSet],
                          activeSetColors: [activeColor],
                          focusedCardIndices: visibleIndices,
                          focusedHighlightColor: activeColor,
                          showBadges: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottomsheet / Set detail (393x258, #0F172A)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              decoration: const BoxDecoration(
                color: SetColors.bgSlate900,
                border: Border(
                  top: BorderSide(color: SetColors.borderSlate700, width: 1),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag handle (40x4, #334155, radius 2)
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: SetColors.borderSlate700,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Set pagination ('세트 03' + '< 3 / 3 >')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '세트 ${(_currentIndex + 1).toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: SetColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: _currentIndex > 0 ? _prevSet : null,
                            child: Icon(
                              Icons.chevron_left,
                              size: 20,
                              color: _currentIndex > 0
                                  ? SetColors.textSecondary
                                  : SetColors.borderSlate700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_currentIndex + 1} / ${sets.length}',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Mono',
                              fontSize: 13,
                              color: activeColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: _currentIndex < sets.length - 1
                                ? _nextSet
                                : null,
                            child: Icon(
                              Icons.chevron_right,
                              size: 20,
                              color: _currentIndex < sets.length - 1
                                  ? SetColors.textSecondary
                                  : SetColors.borderSlate700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Card references (3 Card number chips 48x30 + '옆으로 밀어 다른 세트 보기')
                  Row(
                    children: [
                      ...List.generate(activeSet.displayNumbers.length, (i) {
                        final isHiddenThird = _twoCardHintOnly && i == 2;
                        final numText =
                            isHiddenThird ? '??' : activeSet.displayNumbers[i];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Container(
                            width: 48,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: activeTint,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: activeColor),
                            ),
                            child: Text(
                              numText,
                              style: TextStyle(
                                fontFamily: 'IBM Plex Mono',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: activeColor,
                              ),
                            ),
                          ),
                        );
                      }),
                      const Spacer(),
                      const Text(
                        '옆으로 밀어 다른 세트 보기',
                        style: TextStyle(
                          fontSize: 11,
                          color: SetColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Rule chips ('모양 일치', '색상 다름', '개수 다름', '채움 일치')
                  Row(
                    children: activeSet.attributeRules
                        .map(
                          (rule) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Container(
                              height: 30,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: SetColors.surfaceSlate800,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                rule,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: SetColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),

                  // Hint toggle ('2장만 힌트 보기')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 18,
                            color: SetColors.textSecondary,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '2장만 힌트 보기',
                            style: TextStyle(
                              fontSize: 14,
                              color: SetColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _twoCardHintOnly,
                        activeColor: SetColors.textPrimary,
                        activeTrackColor: activeColor,
                        inactiveThumbColor: SetColors.textPrimary,
                        inactiveTrackColor: SetColors.borderSlate700,
                        onChanged: (v) =>
                            setState(() => _twoCardHintOnly = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Carousel position indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(sets.length, (idx) {
                      final isSelected = idx == _currentIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isSelected ? 18 : 5,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? activeColor
                              : SetColors.borderSlate700,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
