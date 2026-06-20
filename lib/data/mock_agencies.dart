import 'package:flutter/material.dart';

import '../models/agency.dart';
import '../models/reputation.dart';

const List<Agency> mockAgencies = <Agency>[
  Agency(
    id: 'nasa',
    name: 'NASA',
    country: 'EUA',
    initialBudget: 1200,
    budgetFactor: 1.4,
    costFactor: 1.2,
    specialty: 'Tecnologia, ciencia e missoes tripuladas',
    difficulty: 'Media',
    reputation: Reputation(
      political: 70,
      technical: 65,
      scientific: 75,
      public: 65,
      safety: 60,
    ),
    color: Color(0xFF5CB4FF),
  ),
  Agency(
    id: 'urss',
    name: 'URSS',
    country: 'Russia',
    initialBudget: 1000,
    budgetFactor: 1.1,
    costFactor: 0.9,
    specialty: 'Robustez, lancadores e avanco rapido',
    difficulty: 'Media',
    reputation: Reputation(
      political: 75,
      technical: 70,
      scientific: 60,
      public: 70,
      safety: 50,
    ),
    color: Color(0xFFFF8A65),
  ),
  Agency(
    id: 'esa',
    name: 'ESA',
    country: 'Europa',
    initialBudget: 950,
    budgetFactor: 1.0,
    costFactor: 1.05,
    specialty: 'Ciencia, cooperacao e exploracao robotica',
    difficulty: 'Media',
    reputation: Reputation(
      political: 65,
      technical: 65,
      scientific: 80,
      public: 60,
      safety: 70,
    ),
    color: Color(0xFF8BC34A),
  ),
  Agency(
    id: 'isro',
    name: 'ISRO',
    country: 'India',
    initialBudget: 700,
    budgetFactor: 0.75,
    costFactor: 0.7,
    specialty: 'Eficiencia de custo e missoes economicas',
    difficulty: 'Dificil',
    reputation: Reputation(
      political: 60,
      technical: 60,
      scientific: 65,
      public: 65,
      safety: 55,
    ),
    color: Color(0xFFFFD54F),
  ),
];
