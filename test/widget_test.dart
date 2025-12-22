import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_anti_basi/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: TheAntiBasi(),
      ),
    );

    // Verify app loads with splash screen
    expect(find.text('The Anti-Basi'), findsOneWidget);
    expect(find.text('SMART FRIDGE MANAGER'), findsOneWidget);
  });
}
