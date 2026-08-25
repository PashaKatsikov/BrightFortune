import 'package:flutter_test/flutter_test.dart';

import 'package:bright_fortune/main.dart';

void main() {
  testWidgets('App boots and shows the loading screen', (WidgetTester tester) async {
    await tester.pumpWidget(const BrightFortuneApp());
    await tester.pump();
    expect(find.byType(BrightFortuneApp), findsOneWidget);
  });
}
