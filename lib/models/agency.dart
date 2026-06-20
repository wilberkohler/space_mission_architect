import 'package:flutter/material.dart';

import 'reputation.dart';

class Agency {
  const Agency({
    required this.id,
    required this.name,
    required this.country,
    required this.initialBudget,
    required this.budgetFactor,
    required this.costFactor,
    required this.specialty,
    required this.difficulty,
    required this.reputation,
    required this.color,
  });

  final String id;
  final String name;
  final String country;
  final int initialBudget;
  final double budgetFactor;
  final double costFactor;
  final String specialty;
  final String difficulty;
  final Reputation reputation;
  final Color color;

  // Backward compatibility aliases.
  String get description => specialty;
  int get baseBudget => initialBudget;
  int get initialReputation => reputation.public;
  int get initialScience => reputation.scientific;
  int get initialIndustry => reputation.technical;
  String get flagEmoji => '';
}
