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

  void _showCloudAndScenarioSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: SetColors.surfaceSlate800,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _CloudSettingsAndScenarioSheet(
        apiClient: widget.apiClient,
        onSelectThreeSets: () {
          Navigator.of(ctx).pop();
          widget.onDetectedSets(_previewBoard);
        },
        onSelectEmptySet: () {
          Navigator.of(ctx).pop();
          widget.onEmptySetTriggered();
        },
        onSelectQualityWarning: () {
          Navigator.of(ctx).pop();
          widget.onQualityWarningTriggered();
        },
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
              // Capture controls (345x44): Flash icon | Automatic/Manual pill switch | Cloud/Help icon
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
                    icon: Icons.cloud_outlined,
                    tooltip: '클라우드 서버 주소 설정 및 시나리오 테스트',
                    onPressed: _showCloudAndScenarioSheet,
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
              GestureDetector(
                onTap: _showCloudAndScenarioSheet,
                child: const Row(
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

class _CloudSettingsAndScenarioSheet extends StatefulWidget {
  final ISetApiClient apiClient;
  final VoidCallback onSelectThreeSets;
  final VoidCallback onSelectEmptySet;
  final VoidCallback onSelectQualityWarning;

  const _CloudSettingsAndScenarioSheet({
    required this.apiClient,
    required this.onSelectThreeSets,
    required this.onSelectEmptySet,
    required this.onSelectQualityWarning,
  });

  @override
  State<_CloudSettingsAndScenarioSheet> createState() =>
      _CloudSettingsAndScenarioSheetState();
}

class _CloudSettingsAndScenarioSheetState
    extends State<_CloudSettingsAndScenarioSheet> {
  late final TextEditingController _urlController;
  BackendHealthStatus? _healthStatus;
  String? _validationError;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.apiClient.baseUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _saveAndTestConnection() async {
    setState(() {
      _validationError = null;
      _checking = true;
    });
    try {
      widget.apiClient.updateBaseUrl(_urlController.text);
      final status = await widget.apiClient.checkHealth();
      if (mounted) {
        setState(() {
          _healthStatus = status;
          _checking = false;
        });
      }
    } on FormatException catch (e) {
      if (mounted) {
        setState(() {
          _validationError = e.message;
          _checking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '클라우드 YOLO 백엔드 연결 설정',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: SetColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Cloud Run / Railway 배포 주소 또는 동일 Wi-Fi PC 서버 주소(예: https://set-detector-api.a.run.app)를 입력하세요.',
                style: TextStyle(
                  fontSize: 12,
                  color: SetColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _urlController,
                style: const TextStyle(
                  fontFamily: 'IBM Plex Mono',
                  fontSize: 13,
                  color: SetColors.textPrimary,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: SetColors.bgSlate900,
                  hintText: 'https://set-detector-api-xxx.a.run.app',
                  errorText: _validationError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: SetColors.borderSlate700),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SetPrimaryButton(
                label: _checking ? '연결 확인 중...' : '서버 주소 저장 및 헬스체크 (/health)',
                icon: Icons.cloud_done_outlined,
                onPressed: _saveAndTestConnection,
              ),
              if (_healthStatus != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SetColors.bgSlate900,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _healthStatus!.isConnected
                          ? SetColors.cyanAccent
                          : SetColors.roseAccent,
                    ),
                  ),
                  child: Text(
                    _healthStatus!.isConnected
                        ? '연결 성공 · 활성 탐지기: ${_healthStatus!.detectorName} (가중치 로드: ${_healthStatus!.weightsLoaded ? "ON" : "Mock 폴백"})'
                        : '서버 오프라인 (${_healthStatus!.errorMessage ?? "연결 불가"}) · 기기 내 오프라인 모드로 동작합니다.',
                    style: TextStyle(
                      fontSize: 12,
                      color: _healthStatus!.isConnected
                          ? SetColors.cyanAccent
                          : SetColors.amberAccent,
                    ),
                  ),
                ),
              ],
              const Divider(height: 28, color: SetColors.borderSlate700),
              const Text(
                '촬영 시나리오 테스트 (Figma 화면 전환)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: SetColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.auto_awesome, color: SetColors.cyanAccent),
                title: const Text('03 탐지 결과 · 3 SETs 발견'),
                subtitle: const Text('12장 카드 중 유효한 3가지 SET 조합 검출'),
                onTap: widget.onSelectThreeSets,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.layers_clear, color: SetColors.amberAccent),
                title: const Text('05 예외 A · 세트 없음 (0 SET)'),
                subtitle: const Text('12장 인식 완료 · 유효한 조합이 없는 경우'),
                onTap: widget.onSelectEmptySet,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.warning_amber_rounded, color: SetColors.roseAccent),
                title: const Text('05B 예외 B · 촬영 품질 확인'),
                subtitle: const Text('흔들림 감지 및 저조도(빛 부족) 경고 화면'),
                onTap: widget.onSelectQualityWarning,
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
            '수동 속성 입력 (오프라인/클라우드 하이브리드 솔버)',
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
