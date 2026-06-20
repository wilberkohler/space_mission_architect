import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

class IntroCrawlWidget extends StatefulWidget {
  const IntroCrawlWidget({
    required this.text,
    super.key,
    this.playing = false,
    this.duration = const Duration(seconds: 90),
  });

  final String text;
  final bool playing;
  final Duration duration;

  @override
  State<IntroCrawlWidget> createState() => _IntroCrawlWidgetState();
}

class _IntroCrawlWidgetState extends State<IntroCrawlWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void didUpdateWidget(IntroCrawlWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
    if (widget.text != oldWidget.text) {
      _controller.reset();
      if (widget.playing) {
        _controller.forward();
      }
    } else if (widget.playing != oldWidget.playing) {
      if (widget.playing) {
        _controller.forward(from: 0);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxTextWidth = constraints.maxWidth > 900 ? 680 : constraints.maxWidth * 0.9;

        return ClipRect(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, _) {
              final double t = _controller.value;
              final double y = lerpDouble(constraints.maxHeight * 1.12, -constraints.maxHeight * 1.5, t) ?? 0;
              final double scale = lerpDouble(0.84, 1.06, t) ?? 1;

              final Matrix4 transform = Matrix4.identity()
                ..setEntry(3, 2, 0.0015)
                ..translate(0.0, y)
                ..scale(scale)
                ..rotateX(0.46);

              return ShaderMask(
                shaderCallback: (Rect rect) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.transparent,
                      Colors.black,
                      Colors.black,
                      Colors.transparent,
                    ],
                    stops: <double>[0.0, 0.04, 0.97, 1.0],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstIn,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Transform(
                    alignment: Alignment.bottomCenter,
                    transform: transform,
                    child: SizedBox(
                      width: maxTextWidth,
                      child: Text(
                        widget.text,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          color: Color(0xFFFFD56E),
                          fontSize: 19,
                          height: 1.65,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.25,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
