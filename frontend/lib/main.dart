import 'package:flutter/material.dart';
import 'models/set_models.dart';
import 'screens/camera_viewfinder_screen.dart';
import 'screens/detection_result_screen.dart';
import 'screens/empty_set_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/quality_warning_screen.dart';
import 'screens/set_detail_screen.dart';
import 'services/set_api_client.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const SetDetectorApp());
}

enum AppFlowStep {
  onboarding,       // 01 시작 안내
  cameraViewfinder, // 02 카메라 · 자동 촬영
  detectionResult,  // 03 탐지 결과 · 3 SETs
  setDetail,        // 04 세트 상세 · 카드 집중
  emptySet,         // 05 예외 A · 세트 없음
  qualityWarning,   // 05B 예외 B · 촬영 품질
}

class SetDetectorApp extends StatefulWidget {
  final ISetApiClient? apiClient;

  const SetDetectorApp({super.key, this.apiClient});

  @override
  State<SetDetectorApp> createState() => _SetDetectorAppState();
}

class _SetDetectorAppState extends State<SetDetectorApp> {
  late final ISetApiClient _apiClient;
  AppFlowStep _step = AppFlowStep.onboarding;
  DetectionResultData _currentResult =
      DetectionResultData.figmaThreeSetsPreset();
  int _selectedSetIndex = 0;

  @override
  void initState() {
    super.initState();
    _apiClient = widget.apiClient ?? HttpSetApiClient();
  }

  Widget _buildActiveScreen() {
    switch (_step) {
      case AppFlowStep.onboarding:
        return OnboardingScreen(
          onStartPressed: () =>
              setState(() => _step = AppFlowStep.cameraViewfinder),
        );

      case AppFlowStep.cameraViewfinder:
        return CameraViewfinderScreen(
          apiClient: _apiClient,
          onDetectedSets: (res) => setState(() {
            _currentResult = res;
            _step = res.sets.isEmpty
                ? AppFlowStep.emptySet
                : AppFlowStep.detectionResult;
          }),
          onEmptySetTriggered: () => setState(() {
            _currentResult = DetectionResultData.figmaZeroSetsPreset();
            _step = AppFlowStep.emptySet;
          }),
          onQualityWarningTriggered: () =>
              setState(() => _step = AppFlowStep.qualityWarning),
        );

      case AppFlowStep.detectionResult:
        return DetectionResultScreen(
          result: _currentResult,
          onRetake: () =>
              setState(() => _step = AppFlowStep.cameraViewfinder),
          onInspectSet: (setIdx) => setState(() {
            _selectedSetIndex = setIdx;
            _step = AppFlowStep.setDetail;
          }),
        );

      case AppFlowStep.setDetail:
        return SetDetailScreen(
          result: _currentResult,
          initialSetIndex: _selectedSetIndex,
          onBack: () =>
              setState(() => _step = AppFlowStep.detectionResult),
          onDone: () =>
              setState(() => _step = AppFlowStep.cameraViewfinder),
        );

      case AppFlowStep.emptySet:
        return EmptySetScreen(
          result: _currentResult,
          onRetakeWithMoreCards: () =>
              setState(() => _step = AppFlowStep.cameraViewfinder),
        );

      case AppFlowStep.qualityWarning:
        return QualityWarningScreen(
          onRetryCapture: () =>
              setState(() => _step = AppFlowStep.cameraViewfinder),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Set Detector',
      debugShowCheckedModeBanner: false,
      theme: SetTheme.darkTheme,
      home: _buildActiveScreen(),
    );
  }
}
