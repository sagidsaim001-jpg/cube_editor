import 'package:material_ui/material_ui.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const CubeEditorApp());
}

class CubeEditorApp extends StatelessWidget {
  const CubeEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cube Editor',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF6C5CE7),
      ),
      home: const HomeScreen(),
    );
  }
}
