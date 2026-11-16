import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _player = AudioPlayer();
  List<SongModel> _songs = [];
  bool _loading = true;
  bool _denied = false;
  String? _loadError;
  int? _previewingId;
  SongModel? _selected;
  Timer? _previewLimit;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _denied = false; _loadError = null; });
    try {
      final granted = await _audioQuery.checkAndRequest(retryRequest: true);
      if (!mounted) return;
      if (!granted) {
        setState(() { _loading = false; _denied = true; });
        return;
      }
      final songs = await _audioQuery.querySongs(
        sortType: SongSortType.DATE_ADDED,
        orderType: OrderType.DESC_OR_GREATER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );
      if (!mounted) return;
      setState(() { _songs = songs; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _loading = false; _loadError = 'Gaane load nahi ho sake. Dobara koshish karein.'; });
    }
  }

  Future<void> _preview(SongModel song) async {
    if (song.uri == null) return;
    _previewLimit?.cancel();
    try {
      if (_previewingId == song.id && _player.playing) {
        await _player.pause();
        if (mounted) setState(() => _previewingId = null);
        return;
      }
      await _player.stop();
      await _player.setUrl(song.uri!);
      if (!mounted) return;
      setState(() => _previewingId = song.id);
      await _player.play();
      _previewLimit = Timer(const Duration(seconds: 25), () async {
        await _player.pause();
        if (mounted) setState(() => _previewingId = null);
      });
    } catch (_) {
      if (mounted) {
        setState(() => _previewingId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Is gaane ka preview play nahi ho saka')),
        );
      }
    }
  }

  @override
  void dispose() {
    _previewLimit?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_denied) {
      body = Center(child: FilledButton(onPressed: _load, child: const Text('Permission dein')));
    } else if (_loadError != null) {
      body = Center(child: FilledButton(onPressed: _load, child: Text(_loadError!)));
    } else if (_songs.isEmpty) {
      body = const Center(child: Text('Koi gaana nahi mila'));
    } else {
      body = ListView.builder(
        itemCount: _songs.length,
        itemBuilder: (context, i) {
          final song = _songs[i];
          final selected = _selected?.id == song.id;
          return ListTile(
            leading: CircleAvatar(child: Icon(selected ? Icons.check : Icons.music_note)),
            title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(song.artist ?? 'Unknown artist'),
            trailing: IconButton(
              tooltip: _previewingId == song.id ? 'Pause preview' : 'Preview 25 seconds',
              icon: Icon(_previewingId == song.id ? Icons.pause_circle : Icons.play_circle),
              onPressed: () => _preview(song),
            ),
            onTap: () => setState(() => _selected = song),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Device ke Gaane')),
      body: body,
      bottomNavigationBar: _selected == null ? null : SafeArea(
        minimum: const EdgeInsets.all(12),
        child: SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: () {
              _previewLimit?.cancel();
              _player.stop();
              Navigator.pop(context, {
                'title': _selected!.title,
                'artist': _selected!.artist ?? 'Unknown artist',
                'uri': _selected!.uri!,
              });
            },
            icon: const Icon(Icons.check),
            label: const Text('Use this song'),
          ),
        ),
      ),
    );
  }
}
