import 'package:flutter/material.dart';
import '../models/set_models.dart';
import '../services/set_api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/playing_card_widget.dart';

/// Figma Frame 02: '02  카메라 · 자동 촬영' (CameraViewfinderScreen, 393x852).
class CameraViewfinderScreen extends StatefulWidget {
  final ISetApiClient apiClient;
  final ValueChanged<DetectionResultData> onDetectedSets;
  final VoidCallback onEmptySetTriggered;
  final VoidCallback onQualityWarningTriggered;

  const CameraViewfinderScreen({
    super.key,
    required this.apiClient,
    required this.onDetectedSets,
    required this.onEmptySetTriggered,
    required this.onQualityWarningTriggered,
  });

  @override
  State<CameraViewfinderScreen> createState() => _CameraViewfinderScreenState();
}

class _CameraViewfinderScreenState extends State<CameraViewfinderScreen> {
  bool _isAutoMode = true;
  bool _flashOff = true;
  final DetectionResultData _previewBoard =
      DetectionResultData.figmaThreeSetsPreset();

  void _openManualSolverSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: SetColors.bgSlate900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _OfflineManualSolverSheet(
        apiClient: widget.apiClient,
        initialCards: _previewBoard.cards,
        onSolved: (result) {
          Navigator.of(ctx).pop();
          if (result.sets.isEmpty) {
            widget.onEmptySetTriggered();
          } else {
            widget.onDetectedSets(result);
          }
        },
      ),
    );
  }

  void _showScenarioSelector() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: SetColors.surfaceSlate800,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '촬영 시나리오 테스트 (Figma 화면 전환)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: SetColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.auto_awesome, color: SetColors.cyanAccent),
                title: const Text('03 탐지 결과 · 3 SETs 발견'),
                subtitle: const Text('12장 카드 중 유효한 3가지 SET 조합 검출'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  widget.onDetectedSets(_previewBoard);
                },
              ),
              ListTile(
                leading: const Icon(Icons.layers_clear, color: SetColors.amberAccent),
                title: const Text('05 예외 A · 세트 없음 (0 SET)'),
                subtitle: const Text('12장 인식 완료 · 유효한 조합이 없는 경우'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  widget.onEmptySetTriggered();
                },
              ),
              ListTile(
                leading: const Icon(Icons.warning_amber_rounded, color: SetColors.roseAccent),
                title: const Text('05B 예외 B · 촬영 품질 확인'),
                subtitle: const Text('흔들림 감지 및 저조도(빛 부족) 경고 화면'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  widget.onQualityWarningTriggered();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SetColors.tabletopBase,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            children: [
              // Capture controls (345x44): Flash icon | Automatic/Manual pill switch | Help icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SetIconButton(
                    icon: _flashOff ? Icons.flash_off : Icons.flash_on,
                    iconColor: _flashOff
                        ? SetColors.textPrimary
                        : SetColors.cyanAccent,
                    tooltip: '플래시 전환',
                    onPressed: () => setState(() => _flashOff = !_flashOff),
                  ),
                  // Capture mode switch (180x40, rgba(15,23,42,0.80), stroke #334155)
                  Container(
                    width: 180,
                    height: 40,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: SetColors.glassSlate900,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: SetColors.borderSlate700),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isAutoMode = true),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _isAutoMode
                                    ? SetColors.cyanAccent
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                '자동',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: _isAutoMode
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: _isAutoMode
                                      ? SetColors.bgSlate900
                                      : SetColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isAutoMode = false),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: !_isAutoMode
                                    ? SetColors.cyanAccent
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                '수동',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: !_isAutoMode
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: !_isAutoMode
                                      ? SetColors.bgSlate900
                                      : SetColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SetIconButton(
                    icon: Icons.help_outline,
                    tooltip: '예외 상황 및 화면 전환 테스트',
                    onPressed: _showScenarioSelector,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Realtime status ('실시간 인식 중')
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: SetColors.cyanAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '실시간 인식 중',
                    style: TextStyle(
                      fontSize: 12,
                      color: SetColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Registration overlay (Guide / Twelve card positions 3x4)
              Expanded(
                child: TabletopBoardWidget(
                  cards: _previewBoard.cards,
                  showRegistrationGuide: true,
                  showBadges: false,
                ),
              ),
              const SizedBox(height: 10),

              // Card count ('12 / 12 CARDS' + '기기 내 분석')
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '12 / 12 CARDS',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Mono',
                      fontSize: 12,
                      color: SetColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.memory,
                        size: 14,
                        color: SetColors.cyanAccent,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '기기 내 분석',
                        style: TextStyle(
                          fontSize: 11,
                          color: SetColors.cyanAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Capture guidance
              const Text(
                '카드를 프레임 안에 맞춰주세요',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: SetColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isAutoMode
                    ? '화면이 안정되면 자동으로 촬영합니다.'
                    : '셔터 버튼을 눌러 카드를 촬영하세요.',
                style: const TextStyle(
                  fontSize: 12,
                  color: SetColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // Bottom controls: Album import | Shutter (80x80) | Offline manual attribute input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Album import action
                  SizedBox(
                    width: 88,
                    child: Column(
                      children: [
                        SetIconButton(
                          icon: Icons.image_outlined,
                          tooltip: '앨범 가져오기',
                          onPressed: () =>
                              widget.onDetectedSets(_previewBoard),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '앨범 가져오기',
                          style: TextStyle(
                            fontSize: 12,
                            color: SetColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Capture shutter (80x80 ring + 64x64 face + 8x8 cyan dot)
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () => widget.onDetectedSets(_previewBoard),
                        child: Container(
                          width: 80,
                          height: 80,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: SetColors.textPrimary,
                              width: 2.5,
                            ),
                          ),
                          child: Container(
                            width: 64,
                            height: 64,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: SetColors.textPrimary,
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: SetColors.cyanAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isAutoMode ? '자동 촬영 대기' : '탭하여 촬영',
                        style: const TextStyle(
                          fontSize: 11,
                          color: SetColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  // Offline manual attribute input ('수동 속성 입력' / '오프라인 사용 가능')
                  SizedBox(
                    width: 88,
                    child: Column(
                      children: [
                        SetIconButton(
                          icon: Icons.tune,
                          tooltip: '수동 속성 입력',
                          onPressed: _openManualSolverSheet,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '수동 속성 입력',
                          style: TextStyle(
                            fontSize: 12,
                            color: SetColors.textPrimary,
                          ),
                        ),
                        const Text(
                          '오프라인 사용 가능',
                          style: TextStyle(
                            fontSize: 10,
                            color: SetColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfflineManualSolverSheet extends StatelessWidget {
  final ISetApiClient apiClient;
  final List<DetectedCardItem> initialCards;
  final ValueChanged<DetectionResultData> onSolved;

  const _OfflineManualSolverSheet({
    required this.apiClient,
    required this.initialCards,
    required this.onSolved,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '수동 속성 입력 (오프라인/API 하이브리드 솔버)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: SetColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '현재 12장 카드의 4가지 속성(개수·모양·색상·음영)을 바탕으로 GF(3)^4 Modulo 3 알고리즘으로 유효 세트를 즉시 계산합니다.',
            style: TextStyle(
              fontSize: 12,
              color: SetColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          SetPrimaryButton(
            label: '12장 카드 세트 즉시 판별하기',
            icon: Icons.calculate_outlined,
            onPressed: () async {
              final rawCards = initialCards.map((e) => e.card).toList();
              final sets = await apiClient.solveCards(rawCards);
              onSolved(
                DetectionResultData(
                  cards: initialCards,
                  sets: sets,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
