class WorldCupData {
  static List<Map<String, String>> getFixture() {
    return [
      // --- GRUPO A ---
      {'team_a': 'México', 'team_b': 'Sudáfrica', 'group': 'A', 'date': '2026-06-11'},
      {'team_a': 'Corea del Sur', 'team_b': 'Chequia', 'group': 'A', 'date': '2026-06-11'},
      {'team_a': 'Chequia', 'team_b': 'Sudáfrica', 'group': 'A', 'date': '2026-06-18'},
      {'team_a': 'México', 'team_b': 'Corea del Sur', 'group': 'A', 'date': '2026-06-18'},
      {'team_a': 'Chequia', 'team_b': 'México', 'group': 'A', 'date': '2026-06-24'},
      {'team_a': 'Sudáfrica', 'team_b': 'Corea del Sur', 'group': 'A', 'date': '2026-06-24'},

      // --- GRUPO B ---
      {'team_a': 'Canadá', 'team_b': 'Bosnia y Herzegovina', 'group': 'B', 'date': '2026-06-12'},
      {'team_a': 'Qatar', 'team_b': 'Suiza', 'group': 'B', 'date': '2026-06-13'},
      {'team_a': 'Suiza', 'team_b': 'Bosnia y Herzegovina', 'group': 'B', 'date': '2026-06-18'},
      {'team_a': 'Canadá', 'team_b': 'Qatar', 'group': 'B', 'date': '2026-06-18'},
      {'team_a': 'Suiza', 'team_b': 'Canadá', 'group': 'B', 'date': '2026-06-24'},
      {'team_a': 'Bosnia y Herzegovina', 'team_b': 'Qatar', 'group': 'B', 'date': '2026-06-24'},

      // --- GRUPO C ---
      {'team_a': 'Brasil', 'team_b': 'Marruecos', 'group': 'C', 'date': '2026-06-13'},
      {'team_a': 'Haití', 'team_b': 'Escocia', 'group': 'C', 'date': '2026-06-13'},
      {'team_a': 'Escocia', 'team_b': 'Marruecos', 'group': 'C', 'date': '2026-06-19'},
      {'team_a': 'Brasil', 'team_b': 'Haití', 'group': 'C', 'date': '2026-06-19'},
      {'team_a': 'Escocia', 'team_b': 'Brasil', 'group': 'C', 'date': '2026-06-24'},
      {'team_a': 'Marruecos', 'team_b': 'Haití', 'group': 'C', 'date': '2026-06-24'},

      // --- GRUPO D ---
      {'team_a': 'EE.UU.', 'team_b': 'Paraguay', 'group': 'D', 'date': '2026-06-12'},
      {'team_a': 'Australia', 'team_b': 'Turquía', 'group': 'D', 'date': '2026-06-13'},
      {'team_a': 'EE.UU.', 'team_b': 'Australia', 'group': 'D', 'date': '2026-06-19'},
      {'team_a': 'Turquía', 'team_b': 'Paraguay', 'group': 'D', 'date': '2026-06-19'},
      {'team_a': 'Turquía', 'team_b': 'EE.UU.', 'group': 'D', 'date': '2026-06-25'},
      {'team_a': 'Paraguay', 'team_b': 'Australia', 'group': 'D', 'date': '2026-06-25'},

      // --- GRUPO E ---
      {'team_a': 'Alemania', 'team_b': 'Curazao', 'group': 'E', 'date': '2026-06-14'},
      {'team_a': 'Costa de Marfil', 'team_b': 'Ecuador', 'group': 'E', 'date': '2026-06-14'},
      {'team_a': 'Alemania', 'team_b': 'Costa de Marfil', 'group': 'E', 'date': '2026-06-20'},
      {'team_a': 'Ecuador', 'team_b': 'Curazao', 'group': 'E', 'date': '2026-06-20'},
      {'team_a': 'Curazao', 'team_b': 'Costa de Marfil', 'group': 'E', 'date': '2026-06-25'},
      {'team_a': 'Ecuador', 'team_b': 'Alemania', 'group': 'E', 'date': '2026-06-25'},

      // --- GRUPO F ---
      {'team_a': 'Países Bajos', 'team_b': 'Japón', 'group': 'F', 'date': '2026-06-14'},
      {'team_a': 'Suecia', 'team_b': 'Túnez', 'group': 'F', 'date': '2026-06-14'},
      {'team_a': 'Países Bajos', 'team_b': 'Suecia', 'group': 'F', 'date': '2026-06-20'},
      {'team_a': 'Túnez', 'team_b': 'Japón', 'group': 'F', 'date': '2026-06-20'},
      {'team_a': 'Túnez', 'team_b': 'Países Bajos', 'group': 'F', 'date': '2026-06-25'},
      {'team_a': 'Japón', 'team_b': 'Suecia', 'group': 'F', 'date': '2026-06-25'},

      // --- GRUPO G ---
      {'team_a': 'Bélgica', 'team_b': 'Egipto', 'group': 'G', 'date': '2026-06-15'},
      {'team_a': 'Irán', 'team_b': 'Nueva Zelanda', 'group': 'G', 'date': '2026-06-15'},
      {'team_a': 'Bélgica', 'team_b': 'Irán', 'group': 'G', 'date': '2026-06-21'},
      {'team_a': 'Nueva Zelanda', 'team_b': 'Egipto', 'group': 'G', 'date': '2026-06-21'},
      {'team_a': 'Nueva Zelanda', 'team_b': 'Bélgica', 'group': 'G', 'date': '2026-06-26'},
      {'team_a': 'Egipto', 'team_b': 'Irán', 'group': 'G', 'date': '2026-06-26'},

      // --- GRUPO H ---
      {'team_a': 'España', 'team_b': 'Cabo Verde', 'group': 'H', 'date': '2026-06-15'},
      {'team_a': 'Arabia Saudita', 'team_b': 'Uruguay', 'group': 'H', 'date': '2026-06-15'},
      {'team_a': 'España', 'team_b': 'Arabia Saudita', 'group': 'H', 'date': '2026-06-21'},
      {'team_a': 'Cabo Verde', 'team_b': 'Uruguay', 'group': 'H', 'date': '2026-06-21'},
      {'team_a': 'Uruguay', 'team_b': 'España', 'group': 'H', 'date': '2026-06-26'},
      {'team_a': 'Cabo Verde', 'team_b': 'Arabia Saudita', 'group': 'H', 'date': '2026-06-26'},

      // --- GRUPO I ---
      {'team_a': 'Francia', 'team_b': 'Senegal', 'group': 'I', 'date': '2026-06-16'},
      {'team_a': 'Irak', 'team_b': 'Noruega', 'group': 'I', 'date': '2026-06-16'},
      {'team_a': 'Francia', 'team_b': 'Irak', 'group': 'I', 'date': '2026-06-22'},
      {'team_a': 'Noruega', 'team_b': 'Senegal', 'group': 'I', 'date': '2026-06-22'},
      {'team_a': 'Noruega', 'team_b': 'Francia', 'group': 'I', 'date': '2026-06-26'},
      {'team_a': 'Senegal', 'team_b': 'Irak', 'group': 'I', 'date': '2026-06-26'},

      // --- GRUPO J ---
      {'team_a': 'Argentina', 'team_b': 'Argelia', 'group': 'J', 'date': '2026-06-16'},
      {'team_a': 'Austria', 'team_b': 'Jordania', 'group': 'J', 'date': '2026-06-16'},
      {'team_a': 'Argentina', 'team_b': 'Austria', 'group': 'J', 'date': '2026-06-22'},
      {'team_a': 'Jordania', 'team_b': 'Argelia', 'group': 'J', 'date': '2026-06-22'},
      {'team_a': 'Jordania', 'team_b': 'Argentina', 'group': 'J', 'date': '2026-06-27'},
      {'team_a': 'Argelia', 'team_b': 'Austria', 'group': 'J', 'date': '2026-06-27'},

      // --- GRUPO K ---
      {'team_a': 'Portugal', 'team_b': 'Congo DR', 'group': 'K', 'date': '2026-06-17'},
      {'team_a': 'Uzbekistán', 'team_b': 'Colombia', 'group': 'K', 'date': '2026-06-17'},
      {'team_a': 'Portugal', 'team_b': 'Uzbekistán', 'group': 'K', 'date': '2026-06-23'},
      {'team_a': 'Colombia', 'team_b': 'Congo DR', 'group': 'K', 'date': '2026-06-23'},
      {'team_a': 'Congo DR', 'team_b': 'Uzbekistán', 'group': 'K', 'date': '2026-06-27'},
      {'team_a': 'Colombia', 'team_b': 'Portugal', 'group': 'K', 'date': '2026-06-27'},

      // --- GRUPO L ---
      {'team_a': 'Inglaterra', 'team_b': 'Croacia', 'group': 'L', 'date': '2026-06-17'},
      {'team_a': 'Ghana', 'team_b': 'Panamá', 'group': 'L', 'date': '2026-06-17'},
      {'team_a': 'Inglaterra', 'team_b': 'Ghana', 'group': 'L', 'date': '2026-06-23'},
      {'team_a': 'Croacia', 'team_b': 'Panamá', 'group': 'L', 'date': '2026-06-23'},
      {'team_a': 'Panamá', 'team_b': 'Inglaterra', 'group': 'L', 'date': '2026-06-27'},
      {'team_a': 'Ghana', 'team_b': 'Croacia', 'group': 'L', 'date': '2026-06-27'},
    ];
  }
}