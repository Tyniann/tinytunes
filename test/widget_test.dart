import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets('playlist home shell shows app title', (tester) async {
    await pumpApp(tester);

    expect(find.text('TinyTunes'), findsWidgets);
    await endPumpApp(tester);
  });
}
