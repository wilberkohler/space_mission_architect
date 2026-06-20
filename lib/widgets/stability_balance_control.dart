import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum StabilityBalanceState { idle, active, stabilized, unstable, failed }

enum StabilityDriftDirection { left, right }

class StabilityBalanceControl extends StatefulWidget {
  const StabilityBalanceControl({
    required this.state,
    required this.driftDirection,
    required this.driftSpeed,
    required this.safeZoneMin,
    required this.safeZoneMax,
    required this.currentPosition,
    required this.timeLimitSeconds,
    required this.onStabilized,
    required this.onFailed,
    super.key,
  });

  final StabilityBalanceState state;
  final StabilityDriftDirection driftDirection;
  final double driftSpeed;
  final double safeZoneMin;
  final double safeZoneMax;
  final double currentPosition;
  final int timeLimitSeconds;
  final VoidCallback onStabilized;
  final VoidCallback onFailed;

  @override
  State<StabilityBalanceControl> createState() => _StabilityBalanceControlState();
}

class _StabilityBalanceControlState extends State<StabilityBalanceControl> {
  static const double _handleSize = 26;
  static const double _successHoldSeconds = 2.2;

  Timer? _driftTimer;
  DateTime? _lastTickAt;
  double _position = 0.5;
  double _elapsedSeconds = 0;
  double _outsideSafeSeconds = 0;
  double _insideStreakSeconds = 0;
  StabilityBalanceState _visualState = StabilityBalanceState.idle;
  bool _completed = false;

  bool get _isInteractive =>
      widget.state == StabilityBalanceState.active || widget.state == StabilityBalanceState.unstable;

  @override
  void initState() {
    super.initState();
    _position = widget.currentPosition.clamp(0.0, 1.0);
    _visualState = widget.state;
    if (_isInteractive) {
      _startDriftLoop();
    }
  }

  @override
  void didUpdateWidget(covariant StabilityBalanceControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) {
      _visualState = widget.state;
      if (_isInteractive) {
        _startDriftLoop();
      } else {
        _stopDriftLoop();
      }
    }
  }

  @override
  void dispose() {
    _stopDriftLoop();
    super.dispose();
  }

  void _startDriftLoop() {
    _driftTimer ??= Timer.periodic(const Duration(milliseconds: 16), _onDriftTick);
  }

  void _stopDriftLoop() {
    _driftTimer?.cancel();
    _driftTimer = null;
    _lastTickAt = null;
  }

  void _onDriftTick(Timer timer) {
    if (!_isInteractive || _completed) {
      return;
    }

    final DateTime now = DateTime.now();
    final DateTime previous = _lastTickAt ?? now;
    _lastTickAt = now;
    final double delta = (now.difference(previous).inMilliseconds / 1000).clamp(0.0, 0.05);
    if (delta <= 0) {
      return;
    }

    final double direction = widget.driftDirection == StabilityDriftDirection.left ? -1 : 1;
    final double next = (_position + (widget.driftSpeed * direction * delta)).clamp(0.0, 1.0);

    setState(() {
      _position = next;
      _elapsedSeconds += delta;
      _evaluatePosition();
    });
  }

  void _evaluatePosition() {
    final bool insideSafeZone = _position >= widget.safeZoneMin && _position <= widget.safeZoneMax;
    if (insideSafeZone) {
      _insideStreakSeconds += 0.016;
      _outsideSafeSeconds = (_outsideSafeSeconds - 0.022).clamp(0.0, double.infinity);
      _visualState = StabilityBalanceState.active;
    } else {
      _insideStreakSeconds = 0;
      _outsideSafeSeconds += 0.016;
      _visualState = StabilityBalanceState.unstable;
    }

    if (_insideStreakSeconds >= _successHoldSeconds) {
      _completed = true;
      _visualState = StabilityBalanceState.stabilized;
      _stopDriftLoop();
      widget.onStabilized();
      return;
    }

    final double failThreshold = widget.timeLimitSeconds * 0.55;
    if (_elapsedSeconds >= widget.timeLimitSeconds || _outsideSafeSeconds >= failThreshold) {
      _completed = true;
      _visualState = StabilityBalanceState.failed;
      _stopDriftLoop();
      widget.onFailed();
    }
  }

  void _dragTo(double localDx, double width) {
    if (!_isInteractive || _completed) {
      return;
    }
    final double nextPosition = (localDx / width).clamp(0.0, 1.0);
    setState(() {
      _position = nextPosition;
      _evaluatePosition();
    });
  }

  @override
  Widget build(BuildContext context) {
    final StabilityBalanceState effectiveState = _isInteractive ? _visualState : widget.state;
    final Color frameColor = switch (effectiveState) {
      StabilityBalanceState.stabilized => AppColors.green,
      StabilityBalanceState.failed => AppColors.red,
      StabilityBalanceState.unstable => AppColors.yellow,
      StabilityBalanceState.active => AppColors.accent,
      StabilityBalanceState.idle => AppColors.textMuted,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panelLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: frameColor.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Arraste para estabilizar o veiculo',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _statusText(effectiveState),
            style: TextStyle(
              color: frameColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double width = constraints.maxWidth;
              final double safeLeft = widget.safeZoneMin * width;
              final double safeRight = widget.safeZoneMax * width;
              final double handleLeft = (_position * width - (_handleSize / 2)).clamp(0.0, width - _handleSize);

              return MouseRegion(
                cursor: _isInteractive ? SystemMouseCursors.grab : SystemMouseCursors.basic,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragStart: _isInteractive
                      ? (DragStartDetails details) => _dragTo(details.localPosition.dx, width)
                      : null,
                  onHorizontalDragUpdate: _isInteractive
                      ? (DragUpdateDetails details) => _dragTo(details.localPosition.dx, width)
                      : null,
                  onTapDown: _isInteractive ? (TapDownDetails details) => _dragTo(details.localPosition.dx, width) : null,
                  child: SizedBox(
                    height: 66,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        Positioned.fill(
                          child: Center(
                            child: Container(
                              height: 18,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppRadius.circle),
                                gradient: const LinearGradient(
                                  colors: <Color>[
                                    AppColors.red,
                                    AppColors.yellow,
                                    AppColors.green,
                                    AppColors.yellow,
                                    AppColors.red,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 24,
                          left: safeLeft,
                          width: (safeRight - safeLeft).clamp(0.0, width),
                          child: Container(
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.green.withOpacity(0.28),
                              borderRadius: BorderRadius.circular(AppRadius.circle),
                              border: Border.all(color: AppColors.green.withOpacity(0.65)),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 11,
                          left: handleLeft,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 90),
                            width: _handleSize,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.bgDeep,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(color: frameColor, width: 1.4),
                              boxShadow: <BoxShadow>[
                                BoxShadow(color: frameColor.withOpacity(0.18), blurRadius: 12),
                              ],
                            ),
                            child: Icon(Icons.drag_indicator, color: frameColor, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Deriva: ${widget.driftDirection == StabilityDriftDirection.left ? 'esquerda' : 'direita'}  •  velocidade ${(widget.driftSpeed * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ),
              Text(
                'Tempo ${(widget.timeLimitSeconds - _elapsedSeconds).clamp(0, widget.timeLimitSeconds).toStringAsFixed(1)}s',
                style: TextStyle(color: frameColor, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusText(StabilityBalanceState state) {
    return switch (state) {
      StabilityBalanceState.idle => 'Aguardando evento de estabilidade.',
      StabilityBalanceState.active => 'Controle ativo. Mantenha o ponteiro na zona central.',
      StabilityBalanceState.unstable => 'Ponteiro fora da zona segura. Corrija a deriva.',
      StabilityBalanceState.stabilized => 'Estabilidade restaurada manualmente.',
      StabilityBalanceState.failed => 'Falha parcial. O risco da fase aumentou.',
    };
  }
}