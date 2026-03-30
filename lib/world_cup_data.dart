class WorldCupData {
  static List<Map<String, String>> getFixture() {
    return [
      // --- GRUPO A ---
      {'team_a': 'México', 'team_b': 'Jamaica', 'group': 'A', 'date': '2026-06-11'},
      {'team_a': 'Honduras', 'team_b': 'Panamá', 'group': 'A', 'date': '2026-06-11'},
      {'team_a': 'México', 'team_b': 'Honduras', 'group': 'A', 'date': '2026-06-15'},
      {'team_a': 'Jamaica', 'team_b': 'Panamá', 'group': 'A', 'date': '2026-06-15'},
      {'team_a': 'México', 'team_b': 'Panamá', 'group': 'A', 'date': '2026-06-19'},
      {'team_a': 'Jamaica', 'team_b': 'Honduras', 'group': 'A', 'date': '2026-06-19'},

      // --- GRUPO B ---
      {'team_a': 'USA', 'team_b': 'Bolivia', 'group': 'B', 'date': '2026-06-12'},
      {'team_a': 'Uruguay', 'team_b': 'Arabia Saudita', 'group': 'B', 'date': '2026-06-12'},
      {'team_a': 'USA', 'team_b': 'Arabia Saudita', 'group': 'B', 'date': '2026-06-16'},
      {'team_a': 'Bolivia', 'team_b': 'Uruguay', 'group': 'B', 'date': '2026-06-16'},
      {'team_a': 'USA', 'team_b': 'Uruguay', 'group': 'B', 'date': '2026-06-20'},
      {'team_a': 'Bolivia', 'team_b': 'Arabia Saudita', 'group': 'B', 'date': '2026-06-20'},

      // --- GRUPO C ---
      {'team_a': 'Canadá', 'team_b': 'Venezuela', 'group': 'C', 'date': '2026-06-12'},
      {'team_a': 'Chile', 'team_b': 'Serbia', 'group': 'C', 'date': '2026-06-12'},
      {'team_a': 'Canadá', 'team_b': 'Chile', 'group': 'C', 'date': '2026-06-16'},
      {'team_a': 'Venezuela', 'team_b': 'Serbia', 'group': 'C', 'date': '2026-06-16'},
      {'team_a': 'Canadá', 'team_b': 'Serbia', 'group': 'C', 'date': '2026-06-20'},
      {'team_a': 'Venezuela', 'team_b': 'Chile', 'group': 'C', 'date': '2026-06-20'},

      // --- GRUPO D ---
      {'team_a': 'Francia', 'team_b': 'Croacia', 'group': 'D', 'date': '2026-06-13'},
      {'team_a': 'Angola', 'team_b': 'Islandia', 'group': 'D', 'date': '2026-06-13'},
      {'team_a': 'Francia', 'team_b': 'Angola', 'group': 'D', 'date': '2026-06-17'},
      {'team_a': 'Croacia', 'team_b': 'Islandia', 'group': 'D', 'date': '2026-06-17'},
      {'team_a': 'Francia', 'team_b': 'Islandia', 'group': 'D', 'date': '2026-06-21'},
      {'team_a': 'Angola', 'team_b': 'Croacia', 'group': 'D', 'date': '2026-06-21'},

      // --- GRUPO E ---
      {'team_a': 'España', 'team_b': 'Turquía', 'group': 'E', 'date': '2026-06-13'},
      {'team_a': 'Brasil', 'team_b': 'Suiza', 'group': 'E', 'date': '2026-06-13'},
      {'team_a': 'España', 'team_b': 'Brasil', 'group': 'E', 'date': '2026-06-17'},
      {'team_a': 'Turquía', 'team_b': 'Suiza', 'group': 'E', 'date': '2026-06-17'},
      {'team_a': 'España', 'team_b': 'Suiza', 'group': 'E', 'date': '2026-06-21'},
      {'team_a': 'Brasil', 'team_b': 'Turquía', 'group': 'E', 'date': '2026-06-21'},

      // --- GRUPO F ---
      {'team_a': 'Argentina', 'team_b': 'Arabia Saudita', 'group': 'F', 'date': '2026-06-14'},
      {'team_a': 'Australia', 'team_b': 'Egipto', 'group': 'F', 'date': '2026-06-14'},
      {'team_a': 'Argentina', 'team_b': 'Australia', 'group': 'F', 'date': '2026-06-18'},
      {'team_a': 'Arabia Saudita', 'team_b': 'Egipto', 'group': 'F', 'date': '2026-06-18'},
      {'team_a': 'Argentina', 'team_b': 'Egipto', 'group': 'F', 'date': '2026-06-22'},
      {'team_a': 'Australia', 'team_b': 'Arabia Saudita', 'group': 'F', 'date': '2026-06-22'},

      // --- GRUPO G ---
      {'team_a': 'Alemania', 'team_b': 'Escocia', 'group': 'G', 'date': '2026-06-14'},
      {'team_a': 'Portugal', 'team_b': 'Kenia', 'group': 'G', 'date': '2026-06-14'},
      {'team_a': 'Alemania', 'team_b': 'Portugal', 'group': 'G', 'date': '2026-06-18'},
      {'team_a': 'Escocia', 'team_b': 'Kenia', 'group': 'G', 'date': '2026-06-18'},
      {'team_a': 'Alemania', 'team_b': 'Kenia', 'group': 'G', 'date': '2026-06-22'},
      {'team_a': 'Escocia', 'team_b': 'Portugal', 'group': 'G', 'date': '2026-06-22'},

      // --- GRUPO H ---
      {'team_a': 'Marruecos', 'team_b': 'Costa Rica', 'group': 'H', 'date': '2026-06-15'},
      {'team_a': 'Colombia', 'team_b': 'Bélgica', 'group': 'H', 'date': '2026-06-15'},
      {'team_a': 'Colombia', 'team_b': 'Costa Rica', 'group': 'H', 'date': '2026-06-19'},
      {'team_a': 'Marruecos', 'team_b': 'Bélgica', 'group': 'H', 'date': '2026-06-19'},
      {'team_a': 'Colombia', 'team_b': 'Marruecos', 'group': 'H', 'date': '2026-06-23'},
      {'team_a': 'Costa Rica', 'team_b': 'Bélgica', 'group': 'H', 'date': '2026-06-23'},

      // --- GRUPO I ---
      {'team_a': 'Inglaterra', 'team_b': 'Camerún', 'group': 'I', 'date': '2026-06-15'},
      {'team_a': 'Países Bajos', 'team_b': 'Perú', 'group': 'I', 'date': '2026-06-15'},
      {'team_a': 'Inglaterra', 'team_b': 'Países Bajos', 'group': 'I', 'date': '2026-06-19'},
      {'team_a': 'Camerún', 'team_b': 'Perú', 'group': 'I', 'date': '2026-06-19'},
      {'team_a': 'Inglaterra', 'team_b': 'Perú', 'group': 'I', 'date': '2026-06-23'},
      {'team_a': 'Países Bajos', 'team_b': 'Camerún', 'group': 'I', 'date': '2026-06-23'},

      // --- GRUPO J ---
      {'team_a': 'Italia', 'team_b': 'Ecuador', 'group': 'J', 'date': '2026-06-16'},
      {'team_a': 'Irán', 'team_b': 'Corea del Sur', 'group': 'J', 'date': '2026-06-16'},
      {'team_a': 'Italia', 'team_b': 'Irán', 'group': 'J', 'date': '2026-06-20'},
      {'team_a': 'Ecuador', 'team_b': 'Corea del Sur', 'group': 'J', 'date': '2026-06-20'},
      {'team_a': 'Italia', 'team_b': 'Corea del Sur', 'group': 'J', 'date': '2026-06-24'},
      {'team_a': 'Ecuador', 'team_b': 'Irán', 'group': 'J', 'date': '2026-06-24'},

      // --- GRUPO K ---
      {'team_a': 'Japón', 'team_b': 'Senegal', 'group': 'K', 'date': '2026-06-16'},
      {'team_a': 'Polonia', 'team_b': 'Nigeria', 'group': 'K', 'date': '2026-06-16'},
      {'team_a': 'Japón', 'team_b': 'Polonia', 'group': 'K', 'date': '2026-06-20'},
      {'team_a': 'Senegal', 'team_b': 'Nigeria', 'group': 'K', 'date': '2026-06-20'},
      {'team_a': 'Japón', 'team_b': 'Nigeria', 'group': 'K', 'date': '2026-06-24'},
      {'team_a': 'Senegal', 'team_b': 'Polonia', 'group': 'K', 'date': '2026-06-24'},

      // --- GRUPO L ---
      {'team_a': 'República Checa', 'team_b': 'Ghana', 'group': 'L', 'date': '2026-06-17'},
      {'team_a': 'Dinamarca', 'team_b': 'China', 'group': 'L', 'date': '2026-06-17'},
      {'team_a': 'Dinamarca', 'team_b': 'República Checa', 'group': 'L', 'date': '2026-06-21'},
      {'team_a': 'Ghana', 'team_b': 'China', 'group': 'L', 'date': '2026-06-21'},
      {'team_a': 'Dinamarca', 'team_b': 'Ghana', 'group': 'L', 'date': '2026-06-25'},
      {'team_a': 'República Checa', 'team_b': 'China', 'group': 'L', 'date': '2026-06-25'},
    ];
  }
}