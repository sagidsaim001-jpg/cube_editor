import 'package:material_ui/material_ui.dart';

/// One editable side of the cube.
class CubeFace {
  CubeFace({this.color = const Color(0xFF6C5CE7), this.fontFamily, List<String>? texts})
      : texts = texts ?? [];

  Color color;
  String? fontFamily;
  final List<String> texts;

  Map<String, dynamic> toJson() => {
        'color': color.toARGB32(),
        'fontFamily': fontFamily,
        'texts': texts,
      };

  factory CubeFace.fromJson(Map<String, dynamic> json) => CubeFace(
        color: Color((json['color'] as num?)?.toInt() ?? 0xFF6C5CE7),
        fontFamily: json['fontFamily'] as String?,
        texts: (json['texts'] as List?)?.whereType<String>().toList() ?? [],
      );
}

/// Project data. Fields are deliberately JSON-friendly for future timeline data.
class Draft {
  Draft({
    required this.name,
    required this.updated,
    String? id,
    List<CubeFace>? faces,
    this.music,
    this.createdAt,
    this.videoPath,
    this.exportSettings = const {},
    this.lyrics = const [],
    this.keyframes = const [],
  })  : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        faces = faces ?? List.generate(4, (_) => CubeFace()),
        createdAt = createdAt ?? updated;

  final String id;
  String name;
  DateTime updated;
  DateTime createdAt;
  final List<CubeFace> faces;
  String? music;
  String? videoPath;
  Map<String, dynamic> exportSettings;
  List<Map<String, dynamic>> lyrics;
  List<Map<String, dynamic>> keyframes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'updated': updated.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'faces': faces.map((face) => face.toJson()).toList(),
        'music': music,
        'videoPath': videoPath,
        'exportSettings': exportSettings,
        'lyrics': lyrics,
        'keyframes': keyframes,
      };

  factory Draft.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) =>
        DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
    return Draft(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? 'Untitled Project',
      updated: parseDate(json['updated']),
      createdAt: parseDate(json['createdAt'] ?? json['updated']),
      faces: (json['faces'] as List?)
              ?.whereType<Map>()
              .map((face) => CubeFace.fromJson(Map<String, dynamic>.from(face)))
              .toList() ??
          List.generate(4, (_) => CubeFace()),
      music: json['music'] as String?,
      videoPath: json['videoPath'] as String?,
      exportSettings: Map<String, dynamic>.from(json['exportSettings'] as Map? ?? {}),
      lyrics: (json['lyrics'] as List?)
              ?.whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList() ??
          [],
      keyframes: (json['keyframes'] as List?)
              ?.whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList() ??
          [],
    );
  }
}

const List<Color> kSwatches = [
  Color(0xFF6C5CE7),
  Color(0xFFE17055),
  Color(0xFF00B894),
  Color(0xFF0984E3),
  Color(0xFFD63031),
  Color(0xFFFDCB6E),
  Color(0xFF2D3436),
];
