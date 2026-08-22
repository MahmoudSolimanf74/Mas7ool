import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mas7ool/app.dart';

void main() {
  testWidgets('Mas7oolApp bootstrap test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: Mas7oolApp(),
      ),
    );

    // Verify app renders with Arabic Title
    expect(find.text('مسؤول (Mas7ool)'), findsOneWidget);
  });
}
