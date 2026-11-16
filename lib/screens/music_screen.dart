import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

/// Device ke gaane dikhata hai. Gaana tap karne par uska naam wapas jata hai.
class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<SongModel> _songs = [];
  bool _loading = true;
  bool _denied = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _denied = false;
    });

    final granted = await _audioQuery.checkAndRequest(retryRequest: true);
    if (!granted) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _denied = true;
      });
      return;
    }

    final songs = await _audioQuery.querySongs(
      sortType: SongSortType.DATE_ADDED,
      orderType: OrderType.DESC_OR_GREATER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    if (!mounted) return;
    setState(() {
      _songs = songs;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_denied) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Gaano ki permission chahiye'),
            const SizedBox(height: 12),
            FilledButton(onPressed: _load, child: const Text('Permission dein')),
          ],
        ),
      );
    } else if (_songs.isEmpty) {
      body = const Center(child: Text('Koi gaana nahi mila'));
    } else {
      body = ListView.builder(
        itemCount: _songs.length,
        itemBuilder: (context, i) {
          final song = _songs[i];
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.music_note)),
            title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(song.artist ?? 'Unknown artist'),
            onTap: () => Navigator.pop(context, song.title),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Device ke Gaane')),
      body: body,
    );
  }
}
