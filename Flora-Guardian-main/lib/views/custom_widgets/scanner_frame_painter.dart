import 'package:flutter/material.dart';

class ScannerFramePainter extends CustomPainter {
  final double scanLineY;
  final double borderRadius;
  final double cornerLength; // Length of each corner edge

  ScannerFramePainter({
    required this.scanLineY,
    this.borderRadius = 20,
    this.cornerLength = 60, required MaterialColor color, // Add corner length parameter
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0;

    // Draw corners
    // Top left
    _drawCorner(canvas, paint, Offset.zero, 0);
    // Top right
    _drawCorner(canvas, paint, Offset(size.width, 0), 90);
    // Bottom right
    _drawCorner(canvas, paint, Offset(size.width, size.height), 180);
    // Bottom left
    _drawCorner(canvas, paint, Offset(0, size.height), 270);

    // Draw scan line
    paint.color = Colors.black;
    canvas.drawLine(
      Offset(borderRadius, scanLineY),
      Offset(size.width - borderRadius, scanLineY),
      paint,
    );
  }

  void _drawCorner(
    Canvas canvas,
    Paint paint,
    Offset offset,
    double rotationDegrees,
  ) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(rotationDegrees * 3.14159 / 180);

    final path =
        Path()
          ..moveTo(0, cornerLength)
          ..lineTo(0, borderRadius)
          ..arcToPoint(
            Offset(borderRadius, 0),
            radius: Radius.circular(borderRadius),
          )
          ..lineTo(cornerLength, 0);

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(ScannerFramePainter oldDelegate) =>
      oldDelegate.scanLineY != scanLineY;
}
