import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:just_audio/just_audio.dart';

import '../models/draft.dart';
import '../widgets/cube_widget.dart';
import 'music_screen.dart';
import 'lyrics_screen.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key, this.draft});
  final Draft? draft;

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late final Draft _draft;
  final AudioPlayer _audio = AudioPlayer();
  StreamSubscription<Duration>? _positionSub;
  double _rotation = 0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _audioReady = false;

  static const Map<String, String?> _fonts = {
    'Default': null, 'Serif': 'serif', 'Monospace': 'monospace',
  };

  CubeFace get _front => _draft.faces[frontFaceIndex(_rotation, _draft.faces.length)];

  @override
  void initState() {
    super.initState();
    _draft = widget.draft ?? Draft(
      name: 'Project ${DateTime.now().millisecondsSinceEpoch % 10000}',
      updated: DateTime.now(),
    );
    _positionSub = _audio.positionStream.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _audio.durationStream.listen((d) {
      if (d != null && mounted) setState(() => _duration = d);
    });
    if (_draft.musicPath != null) _loadAudio(_draft.musicPath!);
  }

  Future<void> _loadAudio(String uri) async {
    try {
      await _audio.setUrl(uri);
      if (mounted) setState(() => _audioReady = true);
    } catch (_) {
      if (mounted) {
        setState(() => _audioReady = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved song dobara open nahi ho saka.')),
        );
      }
    }
  }

  void _save() {
    _draft.updated = DateTime.now();
    Navigator.pop(context, _draft);
  }

  Future<void> _addText() async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Text likhein'),
        content: TextField(controller: controller, autofocus: true,
          decoration: const InputDecoration(hintText: 'Yahan likhein')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Add')),
        ],
      ),
    );
    if (text != null && text.isNotEmpty) setState(() => _front.texts.add(text));
    controller.dispose();
  }

  Future<void> _pickColor() async {
    bool allFaces = false;
    await showModalBottomSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Color chunein', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SegmentedButton<bool>(
                segments: const [ButtonSegment(value: false, label: Text('Sirf is side')),
                  ButtonSegment(value: true, label: Text('Sab sides'))],
                selected: {allFaces}, onSelectionChanged: (s) => setSheet(() => allFaces = s.first)),
              const SizedBox(height: 16),
              Wrap(spacing: 12, runSpacing: 12, children: [
                for (final c in kSwatches)
                  GestureDetector(onTap: () {
                    setState(() {
                      if (allFaces) { for (final f in _draft.faces) { f.color = c; } }
                      else { _front.color = c; }
                    });
                    Navigator.pop(ctx);
                  }, child: CircleAvatar(backgroundColor: c, radius: 22)),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFont() async {
    await showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        for (final entry in _fonts.entries)
          ListTile(title: Text(entry.key, style: TextStyle(fontFamily: entry.value)),
            onTap: () { setState(() => _front.fontFamily = entry.value); Navigator.pop(ctx); }),
      ])),
    );
  }

  Future<void> _openLyrics() async {
    final lines = await Navigator.push<List<Map<String, dynamic>>>(
      context,
      MaterialPageRoute(builder: (_) => LyricsScreen(player: _audio, initialLyrics: _draft.lyrics)),
    );
    if (lines != null && mounted) setState(() => _draft.lyrics = lines);
  }

  Future<void> _openMusic() async {
    final song = await Navigator.push<Map<String, String>>(
      context, MaterialPageRoute(builder: (_) => const MusicScreen()),
    );
    if (song == null || !mounted) return;
    await _audio.stop();
    _draft.music = song['title'];
    _draft.musicArtist = song['artist'];
    _draft.musicPath = song['uri'];
    await _loadAudio(song['uri']!);
    if (mounted) setState(() {});
  }

  String _time(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes)}:${two(d.inSeconds % 60)}';
  }

  Future<void> _togglePlayback() async {
    if (!_audioReady) return;
    if (_audio.playing) { await _audio.pause(); }
    else { await _audio.play(); }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _audio.dispose();
    super.dispose();
  }

  void _soon(String what) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$what agle step mein aayega')),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(_draft.name),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _save),
        actions: [IconButton(icon: const Icon(Icons.check), tooltip: 'Save', onPressed: _save)]),
      body: Column(children: [
        Expanded(child: Stack(alignment: Alignment.center, children: [
          Container(decoration: const BoxDecoration(gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF1B1B2F), Color(0xFF162447)]))),
          const Positioned(top: 16, child: Text('Video yahan aayegi (agle step mein)',
            style: TextStyle(color: Colors.white38))),
          CubeWidget(faces: _draft.faces, rotation: _rotation, size: 220,
            onRotationChanged: (r) => setState(() => _rotation = r), onFrontTap: _addText),
          const Positioned(bottom: 12, child: Text('Drag: ghumaein  •  Tap: samne wali side par text',
            style: TextStyle(color: Colors.white54, fontSize: 12))),
        ])),
        if (_draft.music != null)
          Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 8), child: Column(children: [
            Row(children: [
              const Icon(Icons.music_note, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text('${_draft.music} • ${_draft.musicArtist ?? ''}',
                maxLines: 1, overflow: TextOverflow.ellipsis)),
              IconButton(onPressed: _openMusic, icon: const Icon(Icons.edit, size: 18)),
            ]),
            Row(children: [
              Text(_time(_position), style: const TextStyle(fontSize: 11)),
              Expanded(child: Slider(
                min: 0, max: _duration.inMilliseconds > 0 ? _duration.inMilliseconds.toDouble() : 1,
                value: _position.inMilliseconds.clamp(0, _duration.inMilliseconds > 0 ? _duration.inMilliseconds : 1).toDouble(),
                onChanged: _audioReady ? (v) => _audio.seek(Duration(milliseconds: v.round())) : null,
              )),
              Text(_time(_duration), style: const TextStyle(fontSize: 11)),
              IconButton(onPressed: _audioReady ? _togglePlayback : null,
                icon: Icon(_audio.playing ? Icons.pause_circle : Icons.play_circle, size: 32)),
            ]),
          ]))
        else
          Padding(padding: const EdgeInsets.all(8), child: TextButton.icon(
            onPressed: _openMusic, icon: const Icon(Icons.music_note), label: const Text('Choose music'))),
        Container(color: const Color(0xFF111111), child: SafeArea(top: false,
          child: Padding(padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _ToolButton(icon: Icons.music_note, label: 'Music', onTap: _openMusic),
              _ToolButton(icon: Icons.text_fields, label: 'Text', onTap: _addText),
              _ToolButton(icon: Icons.font_download, label: 'Fonts', onTap: _pickFont),
              _ToolButton(icon: Icons.palette, label: 'Color', onTap: _pickColor),
              _ToolButton(icon: Icons.lyrics, label: 'Lyrics', onTap: _openLyrics),
            ]))),
        ),
      ]),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap, borderRadius: BorderRadius.circular(12),
    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.white), const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ])),
  );
}
