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

  testWidgets('SetDetectorApp navigates from Onboarding (01) to Camera (02)',
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
  });
}
