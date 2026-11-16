import 'package:flutter_test/flutter_test.dart';
import 'package:cube_editor/main.dart';

void main() {
  testWidgets('Cube Editor home screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const CubeEditorApp());

    expect(find.text('Cube Editor'), findsOneWidget);
    expect(find.text('New Project'), findsOneWidget);
    expect(find.text('Recent Drafts'), findsOneWidget);
  });

  testWidgets('New Project opens the editor', (WidgetTester tester) async {
    await tester.pumpWidget(const CubeEditorApp());

    await tester.tap(find.text('New Project'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Project '), findsOneWidget);
    expect(find.text('Video yahan aayegi (agle step mein)'), findsOneWidget);
    expect(find.text('Keyframe'), findsOneWidget);
  });
}
