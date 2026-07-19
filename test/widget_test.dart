import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/main.dart';

void main() {
  testWidgets('app shows localized title', (tester) async {
    await tester.pumpWidget(const MainApp());
    expect(find.text('TinyTunes'), findsOneWidget);
  });
}
