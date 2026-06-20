class PlayerCareer {
  const PlayerCareer({
    required this.level,
    required this.title,
    required this.experience,
    required this.experienceToNextLevel,
    required this.unlockedResponsibilities,
    required this.salaryOrInfluenceBonus,
    required this.description,
  });

  final int level;
  final String title;
  final int experience;
  final int experienceToNextLevel;
  final List<String> unlockedResponsibilities;
  final double salaryOrInfluenceBonus;
  final String description;

  bool get isMaxLevel => experienceToNextLevel <= 0;

  double get progress {
    if (isMaxLevel) {
      return 1;
    }
    return (experience / experienceToNextLevel).clamp(0, 1).toDouble();
  }

  PlayerCareer copyWith({
    int? level,
    String? title,
    int? experience,
    int? experienceToNextLevel,
    List<String>? unlockedResponsibilities,
    double? salaryOrInfluenceBonus,
    String? description,
  }) {
    return PlayerCareer(
      level: level ?? this.level,
      title: title ?? this.title,
      experience: experience ?? this.experience,
      experienceToNextLevel: experienceToNextLevel ?? this.experienceToNextLevel,
      unlockedResponsibilities:
          unlockedResponsibilities ?? this.unlockedResponsibilities,
      salaryOrInfluenceBonus:
          salaryOrInfluenceBonus ?? this.salaryOrInfluenceBonus,
      description: description ?? this.description,
    );
  }
}
