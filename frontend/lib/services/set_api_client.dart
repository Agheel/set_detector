import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/set_models.dart';

@immutable
class BackendHealthStatus {
  final bool isConnected;
  final String detectorName;
  final bool weightsLoaded;
  final String serverUrl;
  final String? errorMessage;

  const BackendHealthStatus({
    required this.isConnected,
    required this.detectorName,
    required this.weightsLoaded,
    required this.serverUrl,
    this.errorMessage,
  });
}

/// Interface for SET detection & solving backend integration (DIP & ISP).
abstract class ISetApiClient {
  String get baseUrl;
  void updateBaseUrl(String newUrl);
  Future<BackendHealthStatus> checkHealth();
  Future<DetectionResultData> detectImage(Uint8List imageBytes, {String filename});
  Future<List<SetCombinationItem>> solveCards(List<SetCard> cards);
}

/// Pure mathematical GF(3)^4 offline SET solver for on-device & fallback solving.
class OfflineSetSolver {
  const OfflineSetSolver();

  static bool isSet(SetCard a, SetCard b, SetCard c) {
    final nOk = (a.number.value + b.number.value + c.number.value) % 3 == 0;
    final sOk = (a.shape.value + b.shape.value + c.shape.value) % 3 == 0;
    final cOk = (a.color.value + b.color.value + c.color.value) % 3 == 0;
    final shOk = (a.shading.value + b.shading.value + c.shading.value) % 3 == 0;
    return nOk && sOk && cOk && shOk;
  }

  List<SetCombinationItem> findSets(List<SetCard> cards) {
    final found = <SetCombinationItem>[];
    for (var i = 0; i < cards.length; i++) {
      for (var j = i + 1; j < cards.length; j++) {
        for (var k = j + 1; k < cards.length; k++) {
          if (isSet(cards[i], cards[j], cards[k])) {
            found.add(
              SetCombinationItem(
                indices: [i, j, k],
                cards: [cards[i], cards[j], cards[k]],
              ),
            );
          }
        }
      }
    }
    return found;
  }
}

/// Security-first HTTP client connecting to Cloud Run / Railway / Local FastAPI Backend.
class HttpSetApiClient implements ISetApiClient {
  static const int maxUploadBytes = 5 * 1024 * 1024; // 5MB security limit
  static const String defaultCloudUrl =
      String.fromEnvironment('SET_API_BASE_URL', defaultValue: 'http://127.0.0.1:8000');

  String _baseUrl;
  final http.Client _client;
  final OfflineSetSolver _offlineSolver;

  HttpSetApiClient({
    String? baseUrl,
    http.Client? client,
    OfflineSetSolver offlineSolver = const OfflineSetSolver(),
  })  : _baseUrl = validateAndNormalizeUrl(baseUrl ?? defaultCloudUrl),
        _client = client ?? http.Client(),
        _offlineSolver = offlineSolver;

  @override
  String get baseUrl => _baseUrl;

  /// Security validation for user-entered server URL (prevents scheme injection & malformed hosts).
  static String validateAndNormalizeUrl(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('서버 주소를 입력해주세요.');
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      throw const FormatException('올바른 URL 형식이 아닙니다. (예: https://set-api.a.run.app)');
    }
    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') {
      throw const FormatException('보안상 http:// 또는 https:// 프로토콜만 허용됩니다.');
    }
    if (uri.host.isEmpty) {
      throw const FormatException('유효한 호스트명이 필요합니다.');
    }
    final normalized = uri.toString();
    return normalized.endsWith('/')
        ? normalized.substring(0, normalized.length - 1)
        : normalized;
  }

  @override
  void updateBaseUrl(String newUrl) {
    _baseUrl = validateAndNormalizeUrl(newUrl);
  }

  @override
  Future<BackendHealthStatus> checkHealth() async {
    try {
      final uri = Uri.parse('$_baseUrl/health');
      final response = await _client.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return BackendHealthStatus(
          isConnected: true,
          detectorName: (data['detector'] ?? 'Unknown').toString(),
          weightsLoaded: data['weights_loaded'] == true,
          serverUrl: _baseUrl,
        );
      }
      return BackendHealthStatus(
        isConnected: false,
        detectorName: 'Disconnected',
        weightsLoaded: false,
        serverUrl: _baseUrl,
        errorMessage: 'HTTP ${response.statusCode}',
      );
    } catch (e) {
      return BackendHealthStatus(
        isConnected: false,
        detectorName: 'Offline',
        weightsLoaded: false,
        serverUrl: _baseUrl,
        errorMessage: e.toString(),
      );
    }
  }

  void _validatePayloadSecurity(Uint8List bytes) {
    if (bytes.isEmpty) {
      throw const FormatException('업로드할 이미지 데이터가 비어 있습니다.');
    }
    if (bytes.lengthInBytes > maxUploadBytes) {
      throw const FormatException('이미지 크기가 보안 허용치(5MB)를 초과했습니다.');
    }
  }

  @override
  Future<DetectionResultData> detectImage(
    Uint8List imageBytes, {
    String filename = 'capture.jpg',
  }) async {
    _validatePayloadSecurity(imageBytes);

    final uri = Uri.parse('$_baseUrl/api/v1/detect');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: filename,
        ),
      );

    final streamed = await _client.send(request).timeout(
          const Duration(seconds: 10),
        );
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw Exception('서버 분석 오류 (HTTP ${response.statusCode})');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return DetectionResultData.fromJson(decoded);
  }

  @override
  Future<List<SetCombinationItem>> solveCards(List<SetCard> cards) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/v1/solve');
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'cards': cards.map((c) => c.toSolveJson()).toList(),
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rawSets = data['sets'] as List<dynamic>;
        return rawSets
            .map((s) => SetCombinationItem.fromJson(s as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fallback to on-device GF(3)^4 solver when offline ("오프라인 사용 가능")
    }
    return _offlineSolver.findSets(cards);
  }
}
