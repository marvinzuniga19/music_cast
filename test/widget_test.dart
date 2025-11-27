import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_flutter_cast/main.dart';
import 'package:music_flutter_cast/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAudioHandler extends BaseAudioHandler {}

void main() {
  testWidgets('App starts and shows HomeScreen', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Mock AudioHandler
    final mockAudioHandler = MockAudioHandler();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(audioHandler: mockAudioHandler));

    // Verify that HomeScreen is present.
    expect(find.byType(HomeScreen), findsOneWidget);

    // Verify that the title is present
    expect(find.text('Music Cast'), findsOneWidget);
  });
}
