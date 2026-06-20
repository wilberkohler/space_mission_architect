class Reputation {
  const Reputation({
    required this.political,
    required this.technical,
    required this.scientific,
    required this.public,
    required this.safety,
  });

  final int political;
  final int technical;
  final int scientific;
  final int public;
  final int safety;

  int get total => political + technical + scientific + public + safety;

  // Backward compatibility aliases.
  int get publicValue => public;
  int get scientificValue => scientific;
  int get industrialValue => technical;

  Reputation copyWith({int? pub, int? sci, int? ind}) {
    return Reputation(
      political: political,
      technical: (technical + (ind ?? 0)).clamp(0, 200),
      scientific: (scientific + (sci ?? 0)).clamp(0, 200),
      public: (public + (pub ?? 0)).clamp(0, 200),
      safety: safety,
    );
  }
}
