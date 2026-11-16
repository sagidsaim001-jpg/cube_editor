import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/draft.dart';

/// Stores each project as its own JSON file in the app documents directory.
class DraftStorage {
  Future<Directory> _directory() async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory('${root.path}/cube_editor_drafts');
    if (!await directory.exists()) await directory.create(recursive: true);
    return directory;
  }

  Future<List<Draft>> loadAll() async {
    final directory = await _directory();
    final drafts = <Draft>[];
    await for (final entity in directory.list()) {
      if (entity is! File || !entity.path.endsWith('.json')) continue;
      try {
        final decoded = jsonDecode(await entity.readAsString());
        if (decoded is Map) drafts.add(Draft.fromJson(Map<String, dynamic>.from(decoded)));
      } catch (_) {
        // Ignore a damaged draft instead of preventing the home screen from opening.
      }
    }
    drafts.sort((a, b) => b.updated.compareTo(a.updated));
    return drafts;
  }

  Future<void> save(Draft draft) async {
    final directory = await _directory();
    final file = File('${directory.path}/${draft.id}.json');
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(jsonEncode(draft.toJson()), flush: true);
    await temporary.rename(file.path);
  }

  Future<void> delete(Draft draft) async {
    final directory = await _directory();
    final file = File('${directory.path}/${draft.id}.json');
    if (await file.exists()) await file.delete();
  }
}
