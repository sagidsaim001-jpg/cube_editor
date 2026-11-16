import 'package:flutter/material.dart';

/// Ek side (face) of the 3D box.
class CubeFace {
  CubeFace({this.color = const Color(0xFF6C5CE7), this.fontFamily});

  Color color;
  String? fontFamily;
  final List<String> texts = [];
}

/// Ek project / draft jo save hota hai.
class Draft {
  Draft({
    required this.name,
    required this.updated,
    List<CubeFace>? faces,
    this.music,
  }) : faces = faces ?? List.generate(4, (_) => CubeFace());

  String name;
  DateTime updated;
  final List<CubeFace> faces;
  String? music;
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
