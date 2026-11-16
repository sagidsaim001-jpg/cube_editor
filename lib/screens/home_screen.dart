import 'package:material_ui/material_ui.dart';

import '../models/draft.dart';
import '../services/draft_storage.dart';
import 'editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DraftStorage _storage = DraftStorage();
  List<Draft> _drafts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  Future<void> _loadDrafts() async {
    final drafts = await _storage.loadAll();
    if (!mounted) return;
    setState(() {
      _drafts = drafts;
      _loading = false;
    });
  }

  Future<void> _newProject() async {
    final draft = await Navigator.push<Draft>(
      context,
      MaterialPageRoute(builder: (_) => const EditorScreen()),
    );
    if (draft != null) await _upsert(draft);
  }

  Future<void> _openDraft(Draft draft) async {
    final result = await Navigator.push<Draft>(
      context,
      MaterialPageRoute(builder: (_) => EditorScreen(draft: draft)),
    );
    if (result != null) await _upsert(result);
  }

  Future<void> _upsert(Draft draft) async {
    draft.updated = DateTime.now();
    await _storage.save(draft);
    if (!mounted) return;
    setState(() {
      _drafts.removeWhere((item) => item.id == draft.id);
      _drafts.insert(0, draft);
    });
  }

  Future<void> _manageDraft(Draft draft) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const Icon(Icons.edit), title: const Text('Rename'),
            onTap: () => Navigator.pop(ctx, 'rename')),
          ListTile(leading: const Icon(Icons.delete_outline), title: const Text('Delete'),
            onTap: () => Navigator.pop(ctx, 'delete')),
        ]),
      ),
    );
    if (action == 'rename' && mounted) {
      final controller = TextEditingController(text: draft.name);
      final name = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Rename project'),
          content: TextField(controller: controller, autofocus: true,
            decoration: const InputDecoration(labelText: 'Project name')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Save')),
          ],
        ),
      );
      controller.dispose();
      if (name != null && name.isNotEmpty) {
        draft.name = name;
        await _upsert(draft);
      }
    } else if (action == 'delete') {
      await _storage.delete(draft);
      if (mounted) setState(() => _drafts.removeWhere((item) => item.id == draft.id));
    }
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: double.infinity, height: 56,
            child: FilledButton.icon(onPressed: _newProject,
              icon: const Icon(Icons.add),
              label: const Text('New Project', style: TextStyle(fontSize: 18)))),
          const SizedBox(height: 24),
          Text('Recent Drafts', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _drafts.isEmpty
                    ? const Center(child: Text(
                        'Abhi koi draft nahi.\nNew Project se shuru karein.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54)))
                    : ListView.separated(
                        itemCount: _drafts.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final d = _drafts[i];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(width: 48, height: 48,
                              decoration: BoxDecoration(color: d.faces.first.color,
                                borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.view_in_ar, color: Colors.white)),
                            title: Text(d.name),
                            subtitle: Text(_fmt(d.updated)),
                            trailing: IconButton(icon: const Icon(Icons.more_vert),
                              tooltip: 'Draft options', onPressed: () => _manageDraft(d)),
                            onLongPress: () => _manageDraft(d),
                            onTap: () => _openDraft(d),
                          );
                        },
                      ),
          ),
        ]),
      ),
    );
  }
}
