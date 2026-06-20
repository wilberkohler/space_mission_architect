class TeamSpecialty {
  const TeamSpecialty({
    required this.id,
    required this.name,
    required this.assigned,
    required this.recommended,
    required this.costPerMember,
    required this.affects,
  });

  final String id;
  final String name;
  final int assigned;
  final int recommended;
  final int costPerMember;
  final List<String> affects;

  // Backward compatibility aliases.
  String get role => name;
  int get total => recommended;
  String get impactLabel => affects.join(', ');

  double get efficiency => total == 0 ? 0 : assigned / total;

  TeamSpecialty copyWith({int? assigned}) {
    return TeamSpecialty(
      id: id,
      name: name,
      assigned: assigned ?? this.assigned,
      recommended: recommended,
      costPerMember: costPerMember,
      affects: affects,
    );
  }
}
