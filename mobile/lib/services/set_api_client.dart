import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/set_models.dart';

/// Interface for SET detection & solving backend integration (DIP & ISP).
abstract class ISetApiClient {
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

/// Security-first HTTP client connecting to FastAPI SET Detection Backend.
class HttpSetApiClient implements ISetApiClient {
  static const int maxUploadBytes = 5 * 1024 * 1024; // 5MB security limit

  final String baseUrl;
  final http.Client _client;
  final OfflineSetSolver _offlineSolver;

  HttpSetApiClient({
    this.baseUrl = 'http://127.0.0.1:8000',
    http.Client? client,
    OfflineSetSolver offlineSolver = const OfflineSetSolver(),
  })  : _client = client ?? http.Client(),
        _offlineSolver = offlineSolver;

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

    final uri = Uri.parse('$baseUrl/api/v1/detect');
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
      final uri = Uri.parse('$baseUrl/api/v1/solve');
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
