import 'package:flutter_test/flutter_test.dart';

import 'package:molt_musical_media/main.dart';

void main() {
  testWidgets('App renders main navigation and beat maker', (WidgetTester tester) async {
    await tester.pumpWidget(const MoltMusicalMedia());

    expect(find.text('Beat Maker'), findsOneWidget);
    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Create Your Beat 🎵'), findsOneWidget);
  });
}
