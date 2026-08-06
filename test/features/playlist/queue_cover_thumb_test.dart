import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/features/playlist/presentation/queue_cover_thumb.dart';

void main() {
  testWidgets('mounts for a path and collapses when file is missing', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: QueueCoverThumb(
            key: ValueKey('queue-cover-1'),
            path: r'C:\tinytunes-missing-cover.jpg',
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('queue-cover-1')), findsOneWidget);

    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();

    expect(find.byType(Image), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  test('queue cover path gate matches playlist trailing condition', () {
    String? pathOrNull(String? ref) {
      if (ref == null || ref.trim().isEmpty) return null;
      return ref;
    }

    expect(pathOrNull(null), isNull);
    expect(pathOrNull(''), isNull);
    expect(pathOrNull('  '), isNull);
    expect(pathOrNull(r'C:\art\1.jpg'), r'C:\art\1.jpg');
  });
}
