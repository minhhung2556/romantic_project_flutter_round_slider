import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'math.dart';

final _kAngleTween = Tween<double>(begin: 0, end: 360);
final _kValueTween = Tween<double>(begin: 0, end: 1);

enum RoundSliderAlignment { left, right }

class RoundSliderStyle {
  final int stepLineCount;
  final Color borderColor;
  final double borderStroke;
  final double glowDistance;
  final double lineMargin;
  final List<double> lineLengths;
  final Color lineColor;
  final double lineStroke;
  final double friction;
  final double radius;
  final double visibleFactor;
  final RoundSliderAlignment alignment;
  final List<Color> glowColorStops;
  final List<double> glowStops;

  const RoundSliderStyle({
    this.glowColorStops: const [
      Colors.transparent,
      Colors.transparent,
      const Color(0x30ff4b85),
      Colors.transparent,
    ],
    this.glowStops: const [
      0.0,
      0.01,
      0.85,
      1.0,
    ],
    this.alignment: RoundSliderAlignment.right,
    this.visibleFactor: 0.4,
    this.radius: 150.0,
    this.friction: 5.0,
    this.stepLineCount: 150,
    this.borderColor: Colors.pinkAccent,
    this.borderStroke: 3.0,
    this.glowDistance: 30.0,
    this.lineMargin: 4.0,
    this.lineLengths: const <double>[10.0, 14.0, 20.0],
    this.lineColor: Colors.white,
    this.lineStroke: 1.0,
  }) : assert(stepLineCount % 5 == 0 &&
            stepLineCount >= 10 &&
            visibleFactor <= 1 &&
            visibleFactor > 0);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoundSliderStyle &&
          runtimeType == other.runtimeType &&
          stepLineCount == other.stepLineCount &&
          borderColor == other.borderColor &&
          borderStroke == other.borderStroke &&
          glowDistance == other.glowDistance &&
          lineMargin == other.lineMargin &&
          lineLengths == other.lineLengths &&
          lineColor == other.lineColor &&
          lineStroke == other.lineStroke &&
          friction == other.friction &&
          radius == other.radius &&
          visibleFactor == other.visibleFactor &&
          alignment == other.alignment &&
          glowColorStops == other.glowColorStops &&
          glowStops == other.glowStops;

  @override
  int get hashCode =>
      stepLineCount.hashCode ^
      borderColor.hashCode ^
      borderStroke.hashCode ^
      glowDistance.hashCode ^
      lineMargin.hashCode ^
      lineLengths.hashCode ^
      lineColor.hashCode ^
      lineStroke.hashCode ^
      friction.hashCode ^
      radius.hashCode ^
      visibleFactor.hashCode ^
      alignment.hashCode ^
      glowColorStops.hashCode ^
      glowStops.hashCode;
}

class RoundSlider extends StatefulWidget {
  final double value;
  final Function(double value) onChanged;
  final RoundSliderStyle style;
  final Duration animationDuration;

  const RoundSlider({
    Key? key,
    this.style: const RoundSliderStyle(),
    required this.value,
    required this.onChanged,
    this.animationDuration: const Duration(milliseconds: 2000),
  })  : assert(value >= 0 && value <= 1),
        super(key: key);

  @override
  _RoundSliderState createState() => _RoundSliderState();
}

class _RoundSliderState extends State<RoundSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double valueT = 0;
  late Tween<double> valueChangedTween;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: widget.animationDuration);
    _controller.addListener(() {
      if (_controller.isCompleted) {}
      setState(() {});
    });

    _updateFromWidget();

    super.initState();
  }

  void _updateFromWidget() {
    var t = widget.value;
    if (t != valueT) {
      valueChangedTween = Tween(begin: valueT, end: t);
      _controller.forward(from: 0);
    }
    valueT = t;
  }

  @override
  void didUpdateWidget(covariant RoundSlider oldWidget) {
    _updateFromWidget();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width, height;
    height = widget.style.radius * 2;
    width = widget.style.visibleFactor * height;

    var t = _controller.isAnimating
        ? valueChangedTween.evaluate(
            CurveTween(curve: Curves.fastLinearToSlowEaseIn)
                .animate(_controller))
        : valueT;
    var angle = _kAngleTween.transform(t);
    return GestureDetector(
      onPanUpdate: (e) {
        _controller.stop();
        setState(() {
          var factor =
              (widget.style.alignment == RoundSliderAlignment.right ? -1 : 1) *
                  (e.delta.dy / (height * widget.style.friction));
          valueT = math.min(math.max(valueT + factor, 0), 1);
        });
      },
      onPanEnd: (e) {
        setState(() {
          widget.onChanged(_kValueTween.transform(valueT));
        });
      },
      child: CustomPaint(
        painter: _RoundSliderPainter(
          angle: angle,
          style: widget.style,
        ),
        size: Size(width, height),
      ),
    );
  }
}

class _RoundSliderPainter extends CustomPainter {
  /// angle in degree
  final double angle;
  RoundSliderStyle style;

  _RoundSliderPainter({
    this.angle: 0.0,
    required this.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var highlightBrush = Paint()
          ..color = style.borderColor
          ..strokeWidth = style.borderStroke
          ..style = PaintingStyle.stroke
        //
        ;
    var radius = style.radius;
    // var diameter = radius * 2;

    canvas.save();

    // var rect = Rect.fromLTWH(-style.borderStroke, 0.0,
    //     size.width + style.borderStroke * 2, size.height);
    // canvas.clipRect(rect);

    Offset circleCenter;
    switch (style.alignment) {
      case RoundSliderAlignment.left:
        circleCenter = Offset(-(radius - size.width), size.height * 0.5);
        break;
      case RoundSliderAlignment.right:
      default:
        circleCenter = Offset(radius, size.height * 0.5);
        break;
    }

    var startAngle = -90.0 + angle;
    var sweepAngle = -360.0;
    canvas.drawCircle(circleCenter, radius, highlightBrush);

    var da = sweepAngle / style.stepLineCount;
    var brushes = [
      Paint()
        ..color = style.lineColor.withOpacity(0.6)
        ..strokeWidth = style.lineStroke
        ..style = PaintingStyle.stroke,
      Paint()
        ..color = style.lineColor
        ..strokeWidth = style.lineStroke
        ..style = PaintingStyle.stroke,
      Paint()
        ..color = style.lineColor
        ..strokeWidth = style.lineStroke
        ..style = PaintingStyle.stroke,
    ];
    var p0 = circleCenter.translate(
        radius - style.borderStroke - style.lineMargin, 0);
    var p00 = circleCenter.translate(
        radius - style.borderStroke - style.lineMargin - style.lineLengths[0],
        0);
    var p01 = circleCenter.translate(
        radius - style.borderStroke - style.lineMargin - style.lineLengths[1],
        0);
    var p02 = circleCenter.translate(
        radius - style.borderStroke - style.lineMargin - style.lineLengths[2],
        0);

    Offset p2;
    for (var i = 0; i <= style.stepLineCount; ++i) {
      var rotations = startAngle + i * da;
      var p1 = rotate(p0, circleCenter, startAngle + i * da);
      var brush;
      if (i % 10 == 0) {
        p2 = rotate(p02, circleCenter, rotations);
        brush = brushes[2];
      } else if (i % 5 == 0) {
        p2 = rotate(p01, circleCenter, rotations);
        brush = brushes[1];
      } else {
        p2 = rotate(p00, circleCenter, rotations);
        brush = brushes[0];
      }
      canvas.drawLine(p1, p2, brush);
    }

    canvas.drawPath(
        Path()
          ..addOval(Rect.fromCircle(
              center: circleCenter, radius: radius + style.glowDistance)),
        Paint()
          ..style = PaintingStyle.fill
          ..shader = ui.Gradient.radial(
              circleCenter,
              radius + style.glowDistance,
              style.glowColorStops,
              style.glowStops));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RoundSliderPainter oldDelegate) {
    return oldDelegate.angle != angle || oldDelegate.style != style;
  }
}
