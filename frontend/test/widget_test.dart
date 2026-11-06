import 'package:flutter_test/flutter_test.dart';
import 'package:set_detector_mobile/main.dart';
import 'package:set_detector_mobile/models/set_models.dart';
import 'package:set_detector_mobile/services/set_api_client.dart';

void main() {
  test('OfflineSetSolver correctly verifies and finds SET combinations', () {
    const solver = OfflineSetSolver();
    final c1 = SetCard.fromAttributes(1, 1, 1, 1);
    final c2 = SetCard.fromAttributes(2, 2, 2, 2);
    final c3 = SetCard.fromAttributes(3, 3, 3, 3);

    expect(OfflineSetSolver.isSet(c1, c2, c3), isTrue);

    final sets = solver.findSets([c1, c2, c3]);
    expect(sets.length, 1);
    expect(sets.first.formattedReference, '01 · 02 · 03');
  });

  test('HttpSetApiClient validates and normalizes Cloud Run / Railway URLs', () {
    final client = HttpSetApiClient(baseUrl: 'https://set-detector-api.a.run.app/');
    expect(client.baseUrl, 'https://set-detector-api.a.run.app');

    client.updateBaseUrl('https://set-detector.up.railway.app/');
    expect(client.baseUrl, 'https://set-detector.up.railway.app');

    expect(
      () => client.updateBaseUrl('javascript:alert(1)'),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => client.updateBaseUrl(''),
      throwsA(isA<FormatException>()),
    );
  });

  testWidgets(
      'SetDetectorApp navigates through Figma flow (01 -> 02 -> 03 -> 04)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SetDetectorApp());

    // 01 시작 안내
    expect(find.text('Set Detector'), findsOneWidget);
    expect(find.text('카메라 권한 허용 및 시작'), findsOneWidget);

    await tester.tap(find.text('카메라 권한 허용 및 시작'));
    await tester.pumpAndSettle();

    // 02 카메라 · 자동 촬영
    expect(find.text('실시간 인식 중'), findsOneWidget);
    expect(find.text('12 / 12 CARDS'), findsOneWidget);

    await tester.tap(find.text('앨범 가져오기'));
    await tester.pumpAndSettle();

    // 03 탐지 결과 · 세트 존재 여부
    expect(find.text('✨ 세트가 발견되었어요'), findsOneWidget);
    expect(find.text('12장 분석 완료 · 세트 존재 여부 확인'), findsOneWidget);
    expect(find.text('세트가 발견되었어요.'), findsOneWidget);
    expect(find.text('어떤 카드가 세트인지 다음 화면에서 확인해보세요.'), findsOneWidget);
    expect(find.text('세트 조합 보기'), findsOneWidget);

    await tester.tap(find.text('세트 조합 보기'));
    await tester.pumpAndSettle();

    // 04 세트 상세 · 카드 집중
    expect(find.text('세트 상세'), findsOneWidget);
    expect(find.text('2장만 힌트 보기'), findsOneWidget);
  });
}
