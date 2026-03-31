class AppStrings {
  static String idioma = 'es'; // 'es' o 'en'

  // ── APP ───────────────────────────────────────────
  static String get appTitulo =>
      idioma == 'es' ? 'POLLA MUNDIAL' : 'WORLD CUP';

  // ── NAVEGACIÓN ────────────────────────────────────
  static String get navRanking =>
      idioma == 'es' ? 'Ranking' : 'Ranking';
  static String get navPartidos =>
      idioma == 'es' ? 'Partidos' : 'Matches';

  // ── RANKING ───────────────────────────────────────
  static String get tablaPosiciones =>
      idioma == 'es' ? 'TABLA DE POSICIONES' : 'LEADERBOARD';
  static String get registrarJugador =>
      idioma == 'es' ? 'REGISTRAR JUGADOR' : 'ADD PLAYER';
  static String get sinJugadores =>
      idioma == 'es'
      ? 'Aún no hay jugadores\n¡Regístralos para comenzar!'
      : 'No players yet\nAdd them to get started!';

  // ── PARTIDOS ──────────────────────────────────────
  static String get total =>
      idioma == 'es' ? 'Total' : 'Total';
  static String get jugados =>
      idioma == 'es' ? 'Jugados' : 'Played';
  static String get pendientes =>
      idioma == 'es' ? 'Pendientes' : 'Pending';
  static String get progresoTorneo =>
      idioma == 'es' ? 'Progreso del torneo' : 'Tournament progress';
  static String get cargarMundial =>
      idioma == 'es' ? 'Cargar Mundial' : 'Load World Cup';
  static String get partidoManual =>
      idioma == 'es' ? 'Partido Manual' : 'Manual Match';
  static String get buscarEquipo =>
      idioma == 'es' ? 'Buscar equipo...' : 'Search team...';
  static String get sinPartidos =>
      idioma == 'es' ? 'No has creado partidos todavía' : 'No matches yet';
  static String get sinResultados =>
      idioma == 'es'
      ? 'No hay partidos que coincidan'
      : 'No matches found';
  static String get yaHayPartidos =>
      idioma == 'es' ? '⚠️ Ya hay partidos cargados.' : '⚠️ Matches already loaded.';
  static String get fixtureCargado =>
      idioma == 'es' ? '✅ Fixture del Mundial 2026 cargado!' : '✅ World Cup 2026 fixture loaded!';

  // ── DIÁLOGOS ──────────────────────────────────────
  static String get nuevoParticipante =>
      idioma == 'es' ? 'NUEVO PARTICIPANTE' : 'NEW PLAYER';
  static String get ingresaNombre =>
      idioma == 'es' ? 'Ingresa el nombre del jugador' : 'Enter player name';
  static String get nombreParticipante =>
      idioma == 'es' ? 'Nombre del participante' : 'Player name';
  static String get cancelar =>
      idioma == 'es' ? 'Cancelar' : 'Cancel';
  static String get registrar =>
      idioma == 'es' ? 'Registrar' : 'Register';

  static String get nuevoPartido =>
      idioma == 'es' ? 'NUEVO PARTIDO' : 'NEW MATCH';
  static String get equiposEnfrentan =>
      idioma == 'es' ? 'Ingresa los equipos que se enfrentan' : 'Enter the teams';
  static String get equipoLocal =>
      idioma == 'es' ? 'Equipo local' : 'Home team';
  static String get equipoVisitante =>
      idioma == 'es' ? 'Equipo visitante' : 'Away team';
  static String get crearPartido =>
      idioma == 'es' ? 'Crear Partido' : 'Create Match';

  static String get realizarApuesta =>
      idioma == 'es' ? 'REALIZAR APUESTA' : 'PLACE BET';
  static String get quienApuesta =>
      idioma == 'es' ? '¿Quién apuesta?' : 'Who bets?';
  static String get apuestasRegistradas =>
      idioma == 'es' ? 'APUESTAS REGISTRADAS' : 'REGISTERED BETS';
  static String get nadieHaApostado =>
      idioma == 'es' ? 'Nadie ha apostado aún' : 'No bets placed yet';
  static String get confirmar =>
      idioma == 'es' ? 'Confirmar' : 'Confirm';
  static String get apuestaRegistrada =>
      idioma == 'es' ? '¡Apuesta registrada!' : 'Bet registered!';

  static String get resultadoOficial =>
      idioma == 'es' ? 'RESULTADO OFICIAL' : 'OFFICIAL RESULT';
  static String get accionCalculara =>
      idioma == 'es'
      ? 'Esta acción calculará los puntos automáticamente'
      : 'This action will calculate points automatically';
  static String get finalizar =>
      idioma == 'es' ? 'Finalizar' : 'Finish';
  static String get puntosActualizados =>
      idioma == 'es'
      ? '🏆 Puntos calculados y ranking actualizado'
      : '🏆 Points calculated and ranking updated';

  static String get resumenPartido =>
      idioma == 'es' ? 'RESUMEN DEL PARTIDO' : 'MATCH SUMMARY';
  static String get nadiAposto =>
      idioma == 'es' ? 'Nadie apostó en este partido' : 'Nobody bet on this match';
  static String get cerrar =>
      idioma == 'es' ? 'Cerrar' : 'Close';
  static String get aposto =>
      idioma == 'es' ? 'Apostó' : 'Bet';
  static String get exacto =>
      idioma == 'es' ? 'Exacto' : 'Exact';
  static String get ganador =>
      idioma == 'es' ? 'Ganador' : 'Winner';
  static String get fallo =>
      idioma == 'es' ? 'Falló' : 'Wrong';

  static String get eliminarJugador =>
      idioma == 'es' ? 'ELIMINAR JUGADOR' : 'DELETE PLAYER';
  static String eliminarJugadorMsg(String nombre) =>
      idioma == 'es'
      ? '¿Eliminar a $nombre?\nSe borrarán sus puntos y todas sus apuestas.'
      : 'Delete $nombre?\nTheir points and all bets will be removed.';
  static String get eliminar =>
      idioma == 'es' ? 'Eliminar' : 'Delete';

  static String get eliminarPartido =>
      idioma == 'es' ? 'ELIMINAR PARTIDO' : 'DELETE MATCH';
  static String get eliminarPartidoMsg =>
      idioma == 'es'
      ? '\ny todas sus apuestas.\nSi ya tenía resultado, los puntos serán revertidos.'
      : '\nand all its bets.\nIf it had a result, points will be reverted.';
  static String get seEliminara =>
      idioma == 'es' ? 'Se eliminará el partido\n' : 'The match will be deleted\n';

  static String get reiniciarTorneo =>
      idioma == 'es' ? '¡REINICIAR TORNEO!' : 'RESET TOURNAMENT!';
  static String get reiniciarMsg =>
      idioma == 'es'
      ? 'Esta acción eliminará TODOS los jugadores, partidos, apuestas y puntos.\n\nEsta acción no se puede deshacer.'
      : 'This action will delete ALL players, matches, bets and points.\n\nThis cannot be undone.';
  static String get siReiniciar =>
      idioma == 'es' ? 'SÍ, REINICIAR TODO' : 'YES, RESET ALL';

  // ── DETALLE JUGADOR ───────────────────────────────
  static String get estadisticas =>
      idioma == 'es' ? 'ESTADÍSTICAS' : 'STATISTICS';
  static String get historial =>
      idioma == 'es' ? 'HISTORIAL DE APUESTAS' : 'BET HISTORY';
  static String get precision =>
      idioma == 'es' ? 'Precisión' : 'Accuracy';
  static String get sinApuestas =>
      idioma == 'es' ? 'Este jugador aún no ha apostado.' : 'This player has no bets yet.';
  static String get puntosLabel =>
      idioma == 'es' ? 'puntos totales' : 'total points';
  static String get miApuesta =>
      idioma == 'es' ? 'Mi apuesta' : 'My bet';
  static String get resultado =>
      idioma == 'es' ? 'Resultado' : 'Result';
  static String get partidoPendiente =>
      idioma == 'es' ? 'Partido pendiente' : 'Pending match';

  // ── CONFIGURACIÓN ─────────────────────────────────
  static String get configuracion =>
      idioma == 'es' ? 'CONFIGURACIÓN' : 'SETTINGS';
  static String get idiomaTitulo =>
      idioma == 'es' ? 'Idioma' : 'Language';
  static String get idiomaDesc =>
      idioma == 'es' ? 'Selecciona el idioma de la app' : 'Select app language';
  static String get version =>
      idioma == 'es' ? 'Versión' : 'Version';
  static String get acercaDe =>
      idioma == 'es' ? 'Acerca de' : 'About';
  static String get acercaDeDesc =>
      idioma == 'es'
      ? 'Polla Mundial 2026 — Creada con ❤️'
      : 'World Cup Predictor 2026 — Made with ❤️';
}