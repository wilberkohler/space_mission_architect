import 'package:flutter/material.dart';

import '../models/countdown_step.dart';
import '../models/test_option.dart';
import 'countdown_panel.dart';

/// Shows a dialog that runs a test countdown for [test], then resolves with
/// a [TestRunOutcome] on completion or null on cancel.
Future<TestRunOutcome?> showTestCountdown(
  BuildContext context, {
  required TestOption test,
}) {
  return showDialog<TestRunOutcome>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _TestCountdownDialog(test: test),
  );
}

// StatefulWidget so we can capture the NavigatorState before any async gap
// (the 800 ms delay inside CountdownPanel's timer callback).
class _TestCountdownDialog extends StatefulWidget {
  const _TestCountdownDialog({required this.test});

  final TestOption test;

  @override
  State<_TestCountdownDialog> createState() => _TestCountdownDialogState();
}

class _TestCountdownDialogState extends State<_TestCountdownDialog> {
  List<CountdownStep> _stepsForTest() {
    return kTestCountdownSteps[widget.test.id] ??
        kTestCountdownSteps['engine_test']!;
  }

  int _durationForTest() {
    final List<CountdownStep> steps = _stepsForTest();
    if (steps.isEmpty) {
      return 6;
    }
    return steps
            .map((CountdownStep s) => s.triggerAtSecond)
            .reduce((int a, int b) => a > b ? a : b) +
        1;
  }

  void _complete() {
    // Capture navigator before the widget might be detached.
    final NavigatorState nav = Navigator.of(context);
    final TestRunOutcome outcome = TestRunOutcome(
      testId: widget.test.id,
      testName: widget.test.name,
      // A completed countdown is always a pass; warnings reflect low
      // impact tests and are surfaced in the result modal.
      passed: true,
      hasWarning: widget.test.riskReduction < 0.1,
      validatedItems: widget.test.affectedVariables,
      findings: widget.test.possibleFindings.take(2).toList(),
      riskDelta: -widget.test.riskReduction,
      uncertaintyDelta: -widget.test.uncertaintyReduction,
      budgetCost: widget.test.cost,
      description: widget.test.possibleFindings.join(' '),
    );
    nav.pop(outcome);
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final List<CountdownStep> steps = _stepsForTest();
    final int duration = _durationForTest();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        child: SingleChildScrollView(
          child: CountdownPanel(
            type: CountdownType.test,
            // "Verificacao Tecnica" makes it visually distinct from the launch
            // "Contagem de Lancamento" shown later in the flow.
            title: 'Verificacao Tecnica',
            subtitle: widget.test.name,
            durationSeconds: duration,
            steps: steps,
            cancelActionLabel: 'Cancelar verificacao',
            onCompleted: _complete,
            onCancelled: _cancel,
          ),
        ),
      ),
    );
  }
}
