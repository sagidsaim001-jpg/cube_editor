import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/draft.dart';

/// Kaunsi face is waqt samne (front) par hai.
int frontFaceIndex(double rotation, int count) {
  final raw = (-rotation / (math.pi / 2)).round();
  return ((raw % count) + count) % count;
}

/// 3D box jo finger drag se ghumta hai.
/// Drag = ghumana, Tap = samne wali face par text add karna.
class CubeWidget extends StatelessWidget {
  const CubeWidget({
    super.key,
    required this.faces,
    required this.rotation,
    required this.onRotationChanged,
    required this.onFrontTap,
    this.size = 220,
  });

  final List<CubeFace> faces;
  final double rotation;
  final ValueChanged<double> onRotationChanged;
  final VoidCallback onFrontTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final n = faces.length;
    final half = size / 2;
    final visible = <_Placed>[];

    for (var i = 0; i < n; i++) {
      final angle = i * (math.pi / 2) + rotation;
      final facing = math.cos(angle);
      if (facing > 0) visible.add(_Placed(i, angle, facing));
    }
    visible.sort((a, b) => a.facing.compareTo(b.facing));

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: (d) =>
          onRotationChanged(rotation + d.delta.dx * 0.01),
      onTap: onFrontTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            for (final p in visible) _buildFace(faces[p.index], p.angle, half),
          ],
        ),
      ),
    );
  }

  Widget _buildFace(CubeFace face, double angle, double half) {
    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.0012)
      ..rotateY(angle)
      ..translate(0.0, 0.0, half);

    return Transform(
      alignment: Alignment.center,
      transform: transform,
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: face.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24, width: 1.5),
        ),
        child: face.texts.isEmpty
            ? const Center(child: Icon(Icons.add, color: Colors.white54, size: 32))
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final t in face.texts)
                      Text(
                        t,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: face.fontFamily,
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _Placed {
  _Placed(this.index, this.angle, this.facing);
  final int index;
  final double angle;
  final double facing;
}
