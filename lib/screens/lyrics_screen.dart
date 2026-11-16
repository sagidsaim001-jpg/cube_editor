import 'package:material_ui/material_ui.dart';
import 'package:just_audio/just_audio.dart';

class LyricsScreen extends StatefulWidget {
  const LyricsScreen({super.key, required this.player, required this.initialLyrics});
  final AudioPlayer player;
  final List<Map<String, dynamic>> initialLyrics;

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  late final List<Map<String, dynamic>> _lines;
  final TextEditingController _lineController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _lines = widget.initialLyrics.map((line) => Map<String, dynamic>.from(line)).toList();
  }

  String _time(int milliseconds) {
    final d = Duration(milliseconds: milliseconds);
    return '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}.${((d.inMilliseconds % 1000) ~/ 100)}';
  }

  void _syncLine() {
    final text = _lineController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pehle lyric line likhein')),
      );
      return;
    }
    final now = widget.player.position.inMilliseconds;
    setState(() {
      _lines.add({
        'text': text,
        'timeMs': now,
        'endMs': null,
        'faceIndex': 0,
        'rotationDirection': 'right',
        'durationMs': 600,
        'easing': 'easeInOut',
      });
      _lines.sort((a, b) => (a['timeMs'] as int).compareTo(b['timeMs'] as int));
      _lineController.clear();
    });
  }

  @override
  void dispose() {
    _lineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.player.duration?.inMilliseconds ?? 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lyrics Sync'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _lines),
            child: const Text('Save'),
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            StreamBuilder<bool>(
              stream: widget.player.playingStream,
              initialData: widget.player.playing,
              builder: (context, snapshot) => FilledButton.icon(
                onPressed: () async {
                  if (widget.player.playing) {
                    await widget.player.pause();
                  } else if (widget.player.audioSource != null) {
                    await widget.player.play();
                  }
                },
                icon: Icon(snapshot.data == true ? Icons.pause : Icons.play_arrow),
                label: Text(snapshot.data == true ? 'Pause song' : 'Play song for sync'),
              ),
            ),
            const SizedBox(height: 8),
            StreamBuilder<Duration>(
              stream: widget.player.positionStream,
              initialData: widget.player.position,
              builder: (context, snapshot) => Text(
                'Current time: ${_time(snapshot.data?.inMilliseconds ?? 0)}'
                '${duration > 0 ? ' / ${_time(duration)}' : ''}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lineController,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Next lyric line',
                hintText: 'Gaane ki agli line yahan likhein',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _syncLine,
                icon: const Icon(Icons.flag),
                label: const Text('Tap to Sync at current time'),
              ),
            ),
          ]),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            const Expanded(child: Text('Synced lines', style: TextStyle(fontWeight: FontWeight.bold))),
            Text('${_lines.length} lines', style: const TextStyle(color: Colors.white54)),
          ]),
        ),
        Expanded(
          child: _lines.isEmpty
              ? const Center(child: Text('Song play karein aur har line par Tap to Sync dabayein'))
              : ListView.separated(
                  itemCount: _lines.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final line = _lines[index];
                    return ListTile(
                      leading: Text(_time((line['timeMs'] as num).toInt()),
                        style: const TextStyle(color: Color(0xFFB8AFFF))),
                      title: Text(line['text']?.toString() ?? ''),
                      trailing: IconButton(
                        tooltip: 'Delete lyric',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => setState(() => _lines.removeAt(index)),
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}
