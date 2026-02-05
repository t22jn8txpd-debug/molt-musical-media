import 'package:flutter_test/flutter_test.dart';

import 'package:molt_musical_media/app/app.dart';

void main() {
  testWidgets('Molt app boots to auth screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MoltApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
  });
}
