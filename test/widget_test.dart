import 'package:flutter_test/flutter_test.dart';
import 'helpers/mock_firebase.dart';
import 'helpers/test_app.dart';

void main() {
  setUpAll(() async {
    await setupFirebaseForTests();
  });

  testWidgets('shows login screen when not authenticated', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump();
    // AuthController init + login screen fade-in timers
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);

    // Flush remaining animation timers before test ends
    await tester.pump(const Duration(milliseconds: 500));
  });
}
