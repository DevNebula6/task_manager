import 'dart:ui';
import 'package:flutter/material.dart';

class Glassbox extends StatelessWidget {
  const Glassbox({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
    this.blur = 5,
    this.gradient,
    this.borderGradient, 
    this.borderWidth,
  });

  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double blur;
  final Gradient? gradient;
  final Gradient? borderGradient;
  final  double? borderWidth ;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        color: Colors.transparent,
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: Container(),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                gradient: gradient ?? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.4),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                border: borderGradient != null
                    ? GradientBoxBorder(
                        gradient: borderGradient!,
                        width: borderWidth ?? 2, // You can adjust the border width as needed
                      )
                    : Border.all(color: Colors.white.withOpacity(0.2)),
              ),
            ),
            Padding(
              padding: padding,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class GradientBoxBorder extends BoxBorder {
  final Gradient gradient;
  final double width;

  const GradientBoxBorder({
    required this.gradient,
    required this.width ,
  });

  @override
  void paint(Canvas canvas, Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    final Paint paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;

    if (shape == BoxShape.rectangle) {
      if (borderRadius != null) {
        canvas.drawRRect(borderRadius.toRRect(rect), paint);
      } else {
        canvas.drawRect(rect, paint);
      }
    } else {
      canvas.drawCircle(rect.center, rect.shortestSide / 2, paint);
    }
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  ShapeBorder scale(double t) {
    return GradientBoxBorder(
      gradient: gradient,
      width: width * t ,
    );
  }

  @override
  BoxBorder? add(ShapeBorder other, {bool reversed = false}) {
    return null;
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRect(rect.deflate(width));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRect(rect);
  }

  @override
  BorderSide get top => BorderSide(width: width, color: Colors.transparent);

  @override
  BorderSide get bottom => BorderSide(width: width, color: Colors.transparent);

  BorderSide get left => BorderSide(width: width, color: Colors.transparent);

  BorderSide get right => BorderSide(width: width, color: Colors.transparent);

  @override
  bool get isUniform => true;
}
