import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A list marker.
class HtmlListMarker extends LeafRenderObjectWidget {
  /// The marker type.
  final HtmlListMarkerType markerType;

  /// The [TextStyle] to apply to this marker.
  final TextStyle textStyle;

  /// Creates a marker.
  const HtmlListMarker({
    required this.markerType,
    required this.textStyle,
    super.key,
  });

  /// Creates a circle marker.
  const HtmlListMarker.circle(this.textStyle, {super.key})
      : markerType = HtmlListMarkerType.circle;

  /// Creates a disc marker.
  const HtmlListMarker.disc(this.textStyle, {super.key})
      : markerType = HtmlListMarkerType.disc;

  /// Creates a square marker.
  const HtmlListMarker.square(this.textStyle, {super.key})
      : markerType = HtmlListMarkerType.square;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _ListMarkerRenderObject(markerType, textStyle);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('markerType', markerType));
    properties.add(DiagnosticsProperty('textStyle', textStyle));
  }

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _ListMarkerRenderObject)
      ..markerType = markerType
      ..textStyle = textStyle;
  }
}

class _ListMarkerRenderObject extends RenderBox {
  _ListMarkerRenderObject(this._markerType, this._textStyle);

  HtmlListMarkerType _markerType;
  HtmlListMarkerType get markerType => _markerType;
  set markerType(HtmlListMarkerType v) {
    if (v == _markerType) {
      return;
    }

    _markerType = v;
    markNeedsLayout();
  }

  TextPainter? __textPainter;
  final _textMetrics = <LineMetrics>[];
  TextPainter get _textPainter {
    final existingPainter = __textPainter;
    if (existingPainter != null) {
      return existingPainter;
    }

    final newPainter = __textPainter = TextPainter(
      text: TextSpan(style: _textStyle, text: '1.'),
      textDirection: TextDirection.ltr,
    )..layout();

    _textMetrics
      ..clear()
      ..addAll(newPainter.computeLineMetrics());

    return newPainter;
  }

  TextStyle _textStyle;
  TextStyle get textStyle => _textStyle;
  set textStyle(TextStyle v) {
    if (v == _textStyle) {
      return;
    }

    __textPainter = null;
    _textStyle = v;
    markNeedsLayout();
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) =>
      _textPainter.computeDistanceToActualBaseline(baseline);

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      constraints.constrain(_textPainter.size);

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    final m = _textMetrics.isNotEmpty ? _textMetrics.first : null;
    final center = offset +
        Offset(
          size.width / 2,
          (m != null && m.descent.isFinite && m.unscaledAscent.isFinite)
              ? size.height -
                  m.descent -
                  m.unscaledAscent +
                  m.unscaledAscent * .7
              : size.height / 2,
        );

    final color = _textStyle.color;
    final fontSize = _textStyle.fontSize;
    if (color == null || fontSize == null) {
      return;
    }

    final radius = fontSize * .2;
    switch (_markerType) {
      case HtmlListMarkerType.circle:
        canvas.drawCircle(
          center,
          radius * .9,
          Paint()
            ..color = color
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke,
        );
      case HtmlListMarkerType.disc:
        canvas.drawCircle(
          center,
          radius,
          Paint()..color = color,
        );
      case HtmlListMarkerType.disclosureClosed:
        final d = radius * 2;
        canvas
          ..save()
          ..translate(center.dx - d / 2, center.dy - d / 2)
          ..drawPath(
            Path()
              ..lineTo(d, d / 2)
              ..lineTo(0, d),
            Paint()
              ..color = color
              ..style = PaintingStyle.fill,
          )
          ..restore();
      case HtmlListMarkerType.disclosureOpen:
        final d = radius * 2;
        canvas
          ..save()
          ..translate(center.dx - d / 2, center.dy - d / 2)
          ..drawPath(
            Path()
              ..lineTo(d, 0)
              ..lineTo(d / 2, d),
            Paint()
              ..color = color
              ..style = PaintingStyle.fill,
          )
          ..restore();
      case HtmlListMarkerType.square:
        canvas.drawRect(
          Rect.fromCircle(center: center, radius: radius * .8),
          Paint()..color = color,
        );
    }
  }

  @override
  void performLayout() {
    size = computeDryLayout(constraints);
  }
}

/// List marker types.
enum HtmlListMarkerType {
  /// The circle marker type.
  circle,

  /// The disc marker type.
  disc,

  /// The disclosure-closed marker type.
  disclosureClosed,

  /// The disclosure-open marker type.
  disclosureOpen,

  /// The square marker type.
  square,
}
