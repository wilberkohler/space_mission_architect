import 'dart:async';

import 'package:flutter/material.dart';

import '../audio/audio_manager.dart';
import '../audio/sound_effect.dart';
import '../models/countdown_step.dart';
import '../theme/app_theme.dart';

class CountdownPanel extends StatefulWidget {
  const CountdownPanel({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.durationSeconds,
    required this.steps,
    required this.onCompleted,
    required this.onCancelled,
    super.key,
    this.allowCancel = true,
    this.isCritical = false,
    this.cancelActionLabel = 'Cancelar',
    this.systemStatuses = const <SystemGoStatus>[],
  });

  final CountdownType type;
  final String title;
  final String subtitle;
  final int durationSeconds;
  final List<CountdownStep> steps;
  final VoidCallback onCompleted;
  final VoidCallback onCancelled;
  final bool allowCancel;
  final bool isCritical;
  final String cancelActionLabel;
  final List<SystemGoStatus> systemStatuses;

  @override
  State<CountdownPanel> createState() => _CountdownPanelState();
}

class _CountdownPanelState extends State<CountdownPanel>
    with SingleTickerProviderStateMixin {
  late CountdownStatus _status;
  late int _remaining;
  late List<CountdownStep> _steps;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _status = CountdownStatus.preparing;
    _remaining = widget.durationSeconds;
    _steps = List<CountdownStep>.from(widget.steps);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    Future<void>.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _startCountdown();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() => _status = CountdownStatus.running);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        if (_remaining > 0) {
          _remaining -= 1;
          AudioManager.instance.playCountdownBeep(
            remainingSeconds: _remaining,
            isLaunch: widget.type == CountdownType.launch,
          );
          _updateSteps(_remaining);
        } else {
          _timer?.cancel();
          _status = CountdownStatus.completed;
          _markAllCompleted();
          Future<void>.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              widget.onCompleted();
            }
          });
        }
      });
    });
  }

  void _updateSteps(int remaining) {
    final int elapsed = widget.durationSeconds - remaining;
    // Complete every step whose trigger time has been reached, including
    // those previously marked as "running" — without this check, a step
    // promoted to running by the second loop below would never advance to
    // success on the next tick (status != pending → first loop skips it).
    for (int i = 0; i < _steps.length; i++) {
      final CountdownStep step = _steps[i];
      if ((step.status == CountdownStepStatus.pending ||
              step.status == CountdownStepStatus.running) &&
          elapsed >= step.triggerAtSecond) {
        final CountdownStepStatus next = step.isWarning
            ? CountdownStepStatus.warning
            : CountdownStepStatus.success;
        _steps[i] = step.copyWith(status: next);
      }
    }
    // Highlight the next step that hasn't fired yet so the user sees
    // what is about to be validated.
    for (int i = 0; i < _steps.length; i++) {
      if (_steps[i].status == CountdownStepStatus.pending) {
        _steps[i] = _steps[i].copyWith(status: CountdownStepStatus.running);
        break;
      }
    }
  }

  void _markAllCompleted() {
    _steps = _steps.map((CountdownStep s) {
      if (s.status == CountdownStepStatus.pending ||
          s.status == CountdownStepStatus.running) {
        return s.copyWith(status: CountdownStepStatus.success);
      }
      return s;
    }).toList();
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _status = CountdownStatus.paused);
  }

  void _resume() {
    AudioManager.instance.play(SoundEffect.uiClick);
    setState(() => _status = CountdownStatus.running);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        if (_remaining > 0) {
          _remaining -= 1;
          AudioManager.instance.playCountdownBeep(
            remainingSeconds: _remaining,
            isLaunch: widget.type == CountdownType.launch,
          );
          _updateSteps(_remaining);
        } else {
          _timer?.cancel();
          _status = CountdownStatus.completed;
          _markAllCompleted();
          Future<void>.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              widget.onCompleted();
            }
          });
        }
      });
    });
  }

  void _cancel() {
    _timer?.cancel();
    AudioManager.instance.play(SoundEffect.uiBack);
    setState(() => _status = CountdownStatus.cancelled);
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        widget.onCancelled();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isLaunch = widget.type == CountdownType.launch;
    final Color accent = isLaunch ? AppColors.green : AppColors.accent;
    final Color secondary = isLaunch ? AppColors.orange : AppColors.accent;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: accent.withOpacity(0.4), width: 1.5),
        boxShadow: <BoxShadow>[
          BoxShadow(color: accent.withOpacity(0.12), blurRadius: 32, spreadRadius: 2),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _header(accent, secondary),
          _timerSection(accent, secondary),
          const Divider(color: AppColors.panelBorder, height: 1),
          if (widget.systemStatuses.isNotEmpty) ...<Widget>[
            _systemsGoPanel(),
            const Divider(color: AppColors.panelBorder, height: 1),
          ],
          _checklistSection(),
          const SizedBox(height: AppSpacing.sm),
          _progressBar(accent),
          const SizedBox(height: AppSpacing.md),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: _actionButtons(accent),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  Widget _header(Color accent, Color secondary) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.07),
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        border: Border(bottom: BorderSide(color: accent.withOpacity(0.2))),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withOpacity(0.12),
              border: Border.all(color: accent.withOpacity(0.4)),
            ),
            child: Icon(
              widget.type == CountdownType.launch
                  ? Icons.rocket_launch_outlined
                  : Icons.science_outlined,
              size: 18,
              color: accent,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.title.toUpperCase(),
                  style: TextStyle(
                    color: accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  widget.subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _statusChip(),
        ],
      ),
    );
  }

  Widget _statusChip() {
    final bool isLaunch = widget.type == CountdownType.launch;
    final (Color c, String label) = switch (_status) {
      CountdownStatus.preparing => (AppColors.yellow, 'PREPARANDO'),
      // Use accent (cyan) for test running, green only for launch running.
      CountdownStatus.running => (
          isLaunch ? AppColors.green : AppColors.accent,
          isLaunch ? 'CONTAGEM ATIVA' : 'VERIFICANDO'
        ),
      CountdownStatus.paused => (AppColors.orange, 'SUSPENSO'),
      CountdownStatus.completed => (
          isLaunch ? AppColors.green : AppColors.accent,
          isLaunch ? 'LANCADO' : 'APROVADO'
        ),
      CountdownStatus.cancelled => (AppColors.red, 'CANCELADO'),
      CountdownStatus.failed => (AppColors.red, 'FALHA'),
      CountdownStatus.idle => (AppColors.textMuted, 'AGUARDANDO'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: AppDecorations.statusBadge(c),
      child: Text(
        label,
        style: TextStyle(
            color: c, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.8),
      ),
    );
  }

  Widget _timerSection(Color accent, Color secondary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Text(
            'T - ',
            style: TextStyle(
              color: secondary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (BuildContext context, Widget? child) {
              final double opacity = _status == CountdownStatus.running
                  ? 0.8 + _pulseController.value * 0.2
                  : 1.0;
              return Opacity(
                opacity: opacity,
                child: Text(
                  _remaining.toString().padLeft(2, '0'),
                  style: TextStyle(
                    color: accent,
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    height: 1,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _systemsGoPanel() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'STATUS DE SISTEMAS',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: widget.systemStatuses
                .map(
                  (SystemGoStatus s) => KeyedSubtree(
                    key: ValueKey<String>('sys-${s.name}-${s.goState.name}'),
                    child: _systemGoChip(s),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _systemGoChip(SystemGoStatus s) {
    final (Color c, String label) = switch (s.goState) {
      GoState.go => (AppColors.green, 'GO'),
      GoState.warning => (AppColors.orange, 'WARNING'),
      GoState.noGo => (AppColors.red, 'NO-GO'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.circle),
        border: Border.all(color: c.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: c),
          ),
          const SizedBox(width: 5),
          Text(
            '${s.name}: $label',
            style: TextStyle(
                color: c, fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _checklistSection() {
    final bool isLaunch = widget.type == CountdownType.launch;
    final String sectionLabel =
        isLaunch ? 'SEQUENCIA DE LANCAMENTO' : 'PROCEDIMENTO TECNICO';
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            sectionLabel,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Constrain height so long step lists (e.g. integrated_test with
          // 9 steps) don't cause the dialog to overflow the screen.
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _steps
                    .map(
                      (CountdownStep step) => KeyedSubtree(
                        key: ValueKey<String>('step-${step.triggerAtSecond}-${step.label}'),
                        child: _stepRow(step),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepRow(CountdownStep step) {
    final (IconData icon, Color color) = switch (step.status) {
      CountdownStepStatus.pending =>
        (Icons.radio_button_unchecked, AppColors.textMuted),
      CountdownStepStatus.running =>
        (Icons.radio_button_checked, AppColors.accent),
      CountdownStepStatus.success =>
        (Icons.check_circle_outline, AppColors.green),
      CountdownStepStatus.warning =>
        (Icons.warning_amber_outlined, AppColors.orange),
      CountdownStepStatus.failed =>
        (Icons.cancel_outlined, AppColors.red),
    };

    return Padding(
      key: ValueKey<String>('step-row-${step.triggerAtSecond}-${step.label}'),
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              step.label,
              style: TextStyle(
                color: step.status == CountdownStepStatus.pending
                    ? AppColors.textMuted
                    : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: step.status == CountdownStepStatus.running
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressBar(Color accent) {
    final double progress = widget.durationSeconds == 0
        ? 1.0
        : (widget.durationSeconds - _remaining) / widget.durationSeconds;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.circle),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 6,
          backgroundColor: AppColors.panelBorder,
          color: accent,
        ),
      ),
    );
  }

  Widget _actionButtons(Color accent) {
    // ── LAUNCH – paused/hold state ───────────────────────────────────────────
    if (_status == CountdownStatus.paused &&
        widget.type == CountdownType.launch) {
      return Padding(
        key: const ValueKey<String>('launch-paused-actions'),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _actionBtn(
                label: 'Retomar contagem',
                color: AppColors.green,
                onPressed: _resume,
                icon: Icons.play_arrow_rounded,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _actionBtn(
                label: 'Abortar lancamento',
                color: AppColors.red,
                onPressed: _cancel,
                icon: Icons.close_rounded,
              ),
            ),
          ],
        ),
      );
    }

    // No buttons once completed or when cancel is disabled.
    if (!widget.allowCancel || _status == CountdownStatus.completed) {
      return const SizedBox.shrink();
    }

    // ── LAUNCH – running state ───────────────────────────────────────────────
    // Offers a "hold" (pause) option so the operator can decide whether to
    // abort.  Abort is only reachable from the hold state (see above).
    if (widget.type == CountdownType.launch) {
      return Padding(
        key: const ValueKey<String>('launch-running-actions'),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: SizedBox(
          width: double.infinity,
          child: _actionBtn(
            label: 'Segurar contagem',
            color: AppColors.orange,
            onPressed: _pause,
            icon: Icons.pause_rounded,
          ),
        ),
      );
    }

    // ── TEST – running state ─────────────────────────────────────────────────
    // Single "cancel test" button, immediately returns to planning.
    return Padding(
      key: const ValueKey<String>('test-running-actions'),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: SizedBox(
        width: double.infinity,
        child: _actionBtn(
          label: widget.cancelActionLabel,
          color: AppColors.red,
          onPressed: _cancel,
          icon: Icons.close_rounded,
        ),
      ),
    );
  }

  Widget _actionBtn({
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.12),
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.4)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        textStyle:
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

