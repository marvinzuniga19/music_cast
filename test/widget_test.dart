import 'package:flutter_test/flutter_test.dart';
import 'package:music_flutter_cast/main.dart';
import 'package:music_flutter_cast/screens/home_screen.dart';

void main() {
  testWidgets('App starts and shows HomeScreen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that HomeScreen is present.
    expect(find.byType(HomeScreen), findsOneWidget);

    // Verify that the title is present
    expect(find.text('Music Cast'), findsOneWidget);
  });
}
