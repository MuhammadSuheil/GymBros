import 'dart:math' as math;
import 'package:flutter/material.dart';

// Custom Clipper untuk membuat bentuk hexagon (Kembali ke versi awal yang mengisi)
class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double width = size.width;
    final double height = size.height;

    // Koordinat Y kembali normal (mengisi area 0.05 sampai 0.95)
    path.moveTo(width * 0.25, height * 0.05);
    path.lineTo(width * 0.75, height * 0.05);
    path.lineTo(width, height * 0.5);
    path.lineTo(width * 0.75, height * 0.95);
    path.lineTo(width * 0.25, height * 0.95);
    path.lineTo(0, height * 0.5);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// HexagonBorder tetap sama (tidak perlu diubah lagi)
class HexagonBorder extends ShapeBorder {
  final BorderSide side;
  const HexagonBorder({this.side = BorderSide.none});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return HexagonClipper().getClip(rect.size).shift(Offset(rect.left, rect.top));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return HexagonClipper().getClip(rect.size).shift(Offset(rect.left, rect.top));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none || side.width <= 0) return;
    final Paint paint = Paint()
      ..color = side.color
      ..strokeWidth = side.width
      ..style = PaintingStyle.stroke;
    final Path path = getOuterPath(rect, textDirection: textDirection);
    canvas.drawPath(path, paint);
  }

  @override
  ShapeBorder scale(double t) {
     final scaledSide = side.scale(t);
     return HexagonBorder(side: scaledSide ?? BorderSide.none);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HexagonBorder && other.side == side;
  }

  @override
  int get hashCode => side.hashCode;
}

