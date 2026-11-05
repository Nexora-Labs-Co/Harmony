import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/main.dart';

void main() {
  testWidgets('harmony builds', (tester) async {
    await tester.pumpWidget(const HarmonyApp());
    await tester.pumpAndSettle();
    expect(find.text('Buenos días'), findsWidgets);
  });
}
