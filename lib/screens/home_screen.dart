import 'package:material_ui/material_ui.dart';

import '../models/draft.dart';
import 'editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Abhi drafts sirf memory mein hain. Save/load agle step mein.
  final List<Draft> _drafts = [];

  Future<void> _newProject() async {
    final draft = await Navigator.push<Draft>(
      context,
      MaterialPageRoute(builder: (_) => const EditorScreen()),
    );
    if (draft != null) _upsert(draft);
  }

  Future<void> _openDraft(Draft draft) async {
    final result = await Navigator.push<Draft>(
      context,
      MaterialPageRoute(builder: (_) => EditorScreen(draft: draft)),
    );
    if (result != null) _upsert(result);
  }

  void _upsert(Draft draft) {
    setState(() {
      _drafts.remove(draft);
      _drafts.insert(0, draft);
    });
  }

  String _fmt(DateTime t) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(t.day)}/${two(t.month)}/${t.year}  ${two(t.hour)}:${two(t.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cube Editor')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: _newProject,
                icon: const Icon(Icons.add),
                label: const Text('New Project', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 24),
            Text('Recent Drafts', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: _drafts.isEmpty
                  ? const Center(
                      child: Text(
                        'Abhi koi draft nahi.\nNew Project se shuru karein.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _drafts.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final d = _drafts[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: d.faces.first.color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.view_in_ar, color: Colors.white),
                          ),
                          title: Text(d.name),
                          subtitle: Text(_fmt(d.updated)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openDraft(d),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
