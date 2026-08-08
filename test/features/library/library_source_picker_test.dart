import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/features/library/presentation/library_source_picker_dialog.dart';
import 'package:tinytunes/l10n/app_localizations.dart';
import 'package:tinytunes/shared/widgets/google_branding.dart';
import 'package:tinytunes/shared/widgets/microsoft_branding.dart';

void main() {
  testWidgets('source picker offers local, Google Drive, and OneDrive', (
    tester,
  ) async {
    LibrarySourceChoice? choice;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Scaffold(
              body: TextButton(
                onPressed: () async {
                  choice = await showLibrarySourcePicker(context: context);
                },
                child: Text(l10n.addLibrarySourceTitle),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Add music from'));
    await tester.pump();
    await tester.pump();

    expect(find.text('This device'), findsOneWidget);
    expect(find.text('Google Drive'), findsOneWidget);
    expect(find.text('OneDrive'), findsOneWidget);
    expect(find.byType(GoogleDriveMark), findsOneWidget);
    expect(find.byType(OneDriveMark), findsOneWidget);

    await tester.tap(find.text('OneDrive'));
    await tester.pump();
    expect(choice, LibrarySourceChoice.oneDrive);
  });
}
