class AppStrings {
  static String idioma = 'es'; // 'es' o 'en'

  // ── APP ───────────────────────────────────────────
  static String get appTitulo => idioma == 'es' ? 'POLLA MUNDIAL' : 'WORLD CUP';
  static String get appNombre => idioma == 'es' ? 'POLLA MUNDIAL' : 'WORLD CUP';

  // ── NAVEGACIÓN ────────────────────────────────────
  static String get navRanking => idioma == 'es' ? 'Ranking' : 'Ranking';
  static String get navPartidos => idioma == 'es' ? 'Partidos' : 'Matches';

  // ── RANKING ───────────────────────────────────────
  static String get tablaPosiciones =>
      idioma == 'es' ? 'TABLA DE POSICIONES' : 'LEADERBOARD';
  static String get registrarJugador =>
      idioma == 'es' ? 'REGISTRAR JUGADOR' : 'ADD PLAYER';
  static String get sinJugadores => idioma == 'es'
      ? 'Aún no hay jugadores\n¡Regístralos para comenzar!'
      : 'No players yet\nAdd them to get started!';

  // ── PARTIDOS ──────────────────────────────────────
  static String get total => idioma == 'es' ? 'Total' : 'Total';
  static String get jugados => idioma == 'es' ? 'Jugados' : 'Played';
  static String get pendientes => idioma == 'es' ? 'Pendientes' : 'Pending';
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
      idioma == 'es' ? 'No hay partidos que coincidan' : 'No matches found';
  static String get yaHayPartidos => idioma == 'es'
      ? '⚠️ Ya hay partidos cargados.'
      : '⚠️ Matches already loaded.';
  static String get fixtureCargado => idioma == 'es'
      ? '✅ Fixture del Mundial 2026 cargado!'
      : '✅ World Cup 2026 fixture loaded!';

  // ── DIÁLOGOS ──────────────────────────────────────
  static String get nuevoParticipante =>
      idioma == 'es' ? 'NUEVO PARTICIPANTE' : 'NEW PLAYER';
  static String get ingresaNombre =>
      idioma == 'es' ? 'Ingresa el nombre del jugador' : 'Enter player name';
  static String get nombreParticipante =>
      idioma == 'es' ? 'Nombre del participante' : 'Player name';
  static String get cancelar => idioma == 'es' ? 'Cancelar' : 'Cancel';
  static String get registrar => idioma == 'es' ? 'Registrar' : 'Register';

  static String get nuevoPartido =>
      idioma == 'es' ? 'NUEVO PARTIDO' : 'NEW MATCH';
  static String get equiposEnfrentan => idioma == 'es'
      ? 'Ingresa los equipos que se enfrentan'
      : 'Enter the teams';
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
  static String get confirmar => idioma == 'es' ? 'Confirmar' : 'Confirm';
  static String get apuestaRegistrada =>
      idioma == 'es' ? '¡Apuesta registrada!' : 'Bet registered!';

  static String get resultadoOficial =>
      idioma == 'es' ? 'RESULTADO OFICIAL' : 'OFFICIAL RESULT';
  static String get accionCalculara => idioma == 'es'
      ? 'Esta acción calculará los puntos automáticamente'
      : 'This action will calculate points automatically';
  static String get finalizar => idioma == 'es' ? 'Finalizar' : 'Finish';
  static String get puntosActualizados => idioma == 'es'
      ? '🏆 Puntos calculados y ranking actualizado'
      : '🏆 Points calculated and ranking updated';

  static String get resumenPartido =>
      idioma == 'es' ? 'RESUMEN DEL PARTIDO' : 'MATCH SUMMARY';
  static String get nadiAposto => idioma == 'es'
      ? 'Nadie apostó en este partido'
      : 'Nobody bet on this match';
  static String get cerrar => idioma == 'es' ? 'Cerrar' : 'Close';
  static String get aposto => idioma == 'es' ? 'Apostó' : 'Bet';
  static String get exacto => idioma == 'es' ? 'Exacto' : 'Exact';
  static String get ganador => idioma == 'es' ? 'Ganador' : 'Winner';
  static String get fallo => idioma == 'es' ? 'Falló' : 'Wrong';

  static String get eliminarJugador =>
      idioma == 'es' ? 'ELIMINAR JUGADOR' : 'DELETE PLAYER';
  static String eliminarJugadorMsg(String nombre) => idioma == 'es'
      ? '¿Eliminar a $nombre?\nSe borrarán sus puntos y todas sus apuestas.'
      : 'Delete $nombre?\nTheir points and all bets will be removed.';
  static String get eliminar => idioma == 'es' ? 'Eliminar' : 'Delete';

  static String get eliminarPartido =>
      idioma == 'es' ? 'ELIMINAR PARTIDO' : 'DELETE MATCH';
  static String get eliminarPartidoMsg => idioma == 'es'
      ? '\ny todas sus apuestas.\nSi ya tenía resultado, los puntos serán revertidos.'
      : '\nand all its bets.\nIf it had a result, points will be reverted.';
  static String get seEliminara => idioma == 'es'
      ? 'Se eliminará el partido\n'
      : 'The match will be deleted\n';

  static String get reiniciarTorneo =>
      idioma == 'es' ? '¡REINICIAR TORNEO!' : 'RESET TOURNAMENT!';
  static String get reiniciarMsg => idioma == 'es'
      ? 'Esta acción eliminará TODOS los jugadores, partidos, apuestas y puntos.\n\nEsta acción no se puede deshacer.'
      : 'This action will delete ALL players, matches, bets and points.\n\nThis cannot be undone.';
  static String get siReiniciar =>
      idioma == 'es' ? 'SÍ, REINICIAR TODO' : 'YES, RESET ALL';

  // ── DETALLE JUGADOR ───────────────────────────────
  static String get estadisticas =>
      idioma == 'es' ? 'ESTADÍSTICAS' : 'STATISTICS';
  static String get historial =>
      idioma == 'es' ? 'HISTORIAL DE APUESTAS' : 'BET HISTORY';
  static String get precision => idioma == 'es' ? 'Precisión' : 'Accuracy';
  static String get sinApuestas => idioma == 'es'
      ? 'Este jugador aún no ha apostado.'
      : 'This player has no bets yet.';
  static String get puntosLabel =>
      idioma == 'es' ? 'puntos totales' : 'total points';
  static String get miApuesta => idioma == 'es' ? 'Mi apuesta' : 'My bet';
  static String get resultado => idioma == 'es' ? 'Resultado' : 'Result';
  static String get partidoPendiente =>
      idioma == 'es' ? 'Partido pendiente' : 'Pending match';

  // ── CONFIGURACIÓN ─────────────────────────────────
  static String get configuracion =>
      idioma == 'es' ? 'CONFIGURACIÓN' : 'SETTINGS';
  static String get idiomaTitulo => idioma == 'es' ? 'Idioma' : 'Language';
  static String get idiomaDesc =>
      idioma == 'es' ? 'Selecciona el idioma de la app' : 'Select app language';
  static String get version => idioma == 'es' ? 'Versión' : 'Version';
  static String get acercaDe => idioma == 'es' ? 'Acerca de' : 'About';
  static String get acercaDeDesc => idioma == 'es'
      ? 'Polla Mundial 2026 — Creada por Carlos Valencia'
      : 'World Cup Predictor 2026 — Created by Carlos Valencia';

  // ── FLIP CARD ─────────────────────────────────────────────────────
  static String get tocaParaAcciones =>
      idioma == 'es' ? 'Toca para acciones' : 'Tap for actions';
  static String get finalizado => idioma == 'es' ? 'Finalizado' : 'Finished';
  static String get apostar => idioma == 'es' ? 'Apostar' : 'Bet';
  static String get apuestas => idioma == 'es' ? 'Apuestas' : 'Bets';
  static String get grupo => idioma == 'es' ? 'Grupo' : 'Group';

  // ── MODO DE JUEGO ──────────────────────────────────────────────────────────
  static String get modoJuego => idioma == 'es' ? 'Modo de Juego' : 'Game Mode';
  static String get modoJuegoDesc => idioma == 'es'
      ? 'Cómo se calculan los puntos'
      : 'How points are calculated';

  static String get modoClasico => idioma == 'es' ? 'Clásico' : 'Classic';
  static String get modoClasicoDesc => idioma == 'es'
      ? '3 pts marcador exacto · 1 pt ganador/empate'
      : '3 pts exact score · 1 pt winner/draw';

  static String get modoExacto => idioma == 'es' ? 'Solo Exacto' : 'Exact Only';
  static String get modoExactoDesc => idioma == 'es'
      ? '1 pt solo si aciertas el marcador exacto'
      : '1 pt only if you nail the exact score';

  static String get jugadorYaRegistrado => idioma == 'es'
      ? '⚠️ Este jugador ya está registrado.'
      : '⚠️ This player is already registered.';

  static String get fechaNoDisponible =>
      idioma == 'es' ? 'Fecha por confirmar' : 'Date TBD';

  static String get modoPersonalizado =>
      idioma == 'es' ? 'Personalizado' : 'Custom';
  static String get modoPersonalizadoDesc => idioma == 'es'
      ? 'Tú defines los puntos por exacto y ganador'
      : 'You set the points for exact and winner';
  static String get puntosExactoLabel =>
      idioma == 'es' ? 'Pts. marcador exacto' : 'Pts. exact score';
  static String get puntosGanadorLabel =>
      idioma == 'es' ? 'Pts. ganador / empate' : 'Pts. winner / draw';
  static String get soloPremium =>
      idioma == 'es' ? 'Solo Premium 👑' : 'Premium only 👑';

  // ── PREMIUM ───────────────────────────────────────────────────────────────
  static String get premiumTitulo =>
      idioma == 'es' ? '¡HAZTE PREMIUM!' : 'GO PREMIUM!';
  static String get premiumSubtitulo => idioma == 'es'
      ? 'Desbloquea todo para vivir el Mundial al máximo'
      : 'Unlock everything to enjoy the World Cup to the fullest';
  static String get premiumPrecio =>
      idioma == 'es' ? 'Pago único' : 'One-time payment';
  static String get premiumBoton =>
      idioma == 'es' ? 'COMPRAR AHORA' : 'BUY NOW';
  static String get premiumRestaurar =>
      idioma == 'es' ? 'Restaurar compra' : 'Restore purchase';
  static String get premiumActivado =>
      idioma == 'es' ? '🏆 ¡Premium activado!' : '🏆 Premium activated!';
  static String get premiumError => idioma == 'es'
      ? 'No se pudo completar la compra. Intenta de nuevo.'
      : 'Purchase could not be completed. Try again.';
  static String get premiumBloqueado =>
      idioma == 'es' ? 'Función Premium' : 'Premium Feature';
  static String get premiumDescBloqueado => idioma == 'es'
      ? 'Esta función está disponible en la versión Premium'
      : 'This feature is available in the Premium version';

  // Beneficios mostrados en el paywall
  static List<String> get premiumBeneficios => idioma == 'es'
      ? [
          '👥  Jugadores ilimitados',
          '🚫  Sin anuncios',
          '🎮  Modos de juego extra',
          '🏆  Apuesta al campeón',
          '⚽  Fase eliminatoria',
          '📊  Estadísticas con gráficas',
          '📤  Compartir y exportar PDF',
          '🔔  Notificaciones por partido',
          '💾  Backup y restaurar datos',
          '🏟️  Torneos simultáneos',
        ]
      : [
          '👥  Unlimited players',
          '🚫  No ads',
          '🎮  Extra game modes',
          '🏆  Champion bet',
          '⚽  Knockout stage',
          '📊  Stats with charts',
          '📤  Share and export PDF',
          '🔔  Per-match notifications',
          '💾  Backup and restore',
          '🏟️  Simultaneous tournaments',
        ];

  static String get limiteJugadores => idioma == 'es'
      ? '⚠️ Versión gratuita: máximo 6 jugadores'
      : '⚠️ Free version: 6 players maximum';

  // ── APUESTA AL CAMPEÓN ────────────────────────────────────────────────────
  static String get apuestaCampeon =>
      idioma == 'es' ? 'APUESTA AL CAMPEÓN' : 'CHAMPION BET';
  static String get apuestaCampeonDesc => idioma == 'es'
      ? '¿Quién ganará el Mundial 2026?'
      : 'Who will win the 2026 World Cup?';
  static String get seleccionarEquipo =>
      idioma == 'es' ? 'Seleccionar equipo' : 'Select team';
  static String get sinApuestaCampeon =>
      idioma == 'es' ? 'Sin apuesta' : 'No bet';
  static String get declararCampeon =>
      idioma == 'es' ? 'DECLARAR CAMPEÓN' : 'DECLARE CHAMPION';
  static String get campeonActual =>
      idioma == 'es' ? 'Campeón declarado' : 'Declared champion';
  static String get puntosBonusCampeon =>
      idioma == 'es' ? 'Pts. por acertar campeón' : 'Pts. for correct champion';
  static String get campeonDeclaradoMsg => idioma == 'es'
      ? '🏆 ¡Campeón declarado y puntos repartidos!'
      : '🏆 Champion declared and points awarded!';
  static String get resetearCampeon =>
      idioma == 'es' ? 'Resetear campeón' : 'Reset champion';
  static String get acertaronCampeon =>
      idioma == 'es' ? 'Acertaron el campeón' : 'Got the champion right';
  static String get nadieAcerto =>
      idioma == 'es' ? 'Nadie acertó el campeón' : 'Nobody got the champion';
  static String get tuApuesta => idioma == 'es' ? 'Tu apuesta' : 'Your bet';

  // ── ELIMINATORIAS ─────────────────────────────────────────────────────────
  static String get eliminatorias =>
      idioma == 'es' ? 'Eliminatorias' : 'Knockout';
  static String get nuevaRonda => idioma == 'es' ? 'NUEVA RONDA' : 'NEW ROUND';
  static String get nombreRonda =>
      idioma == 'es' ? 'Nombre de la ronda' : 'Round name';
  static String get sinRondas => idioma == 'es'
      ? 'Aún no hay rondas\nCrea la primera ronda eliminatoria'
      : 'No rounds yet\nCreate the first knockout round';
  static String get sinPartidosRonda => idioma == 'es'
      ? 'Sin partidos en esta ronda'
      : 'No matches in this round';
  static String get agregarPartido =>
      idioma == 'es' ? 'Agregar Partido' : 'Add Match';
  static String get eliminarRonda =>
      idioma == 'es' ? 'ELIMINAR RONDA' : 'DELETE ROUND';
  static String get eliminarRondaMsg => idioma == 'es'
      ? 'Se eliminarán todos los partidos y apuestas de esta ronda.'
      : 'All matches and bets in this round will be deleted.';
  static String get rondasPredefinidas =>
      idioma == 'es' ? 'Rondas sugeridas' : 'Suggested rounds';

  // Nombres de rondas predefinidas
  static List<String> get rondasSugeridas => idioma == 'es'
      ? [
          'Dieciseisavos de final',
          'Octavos de final',
          'Cuartos de final',
          'Semifinales',
          'Tercer puesto',
          'Final',
        ]
      : [
          'Round of 32',
          'Round of 16',
          'Quarter-finals',
          'Semi-finals',
          'Third place',
          'Final',
        ];
  
  // ── TORNEOS ───────────────────────────────────────────────────────────────
  static String get torneos =>
      idioma == 'es' ? 'Torneos' : 'Tournaments';
  static String get nuevoTorneo =>
      idioma == 'es' ? 'NUEVO TORNEO' : 'NEW TOURNAMENT';
  static String get nombreTorneo =>
      idioma == 'es' ? 'Nombre del torneo' : 'Tournament name';
  static String get ingresaNombreTorneo =>
      idioma == 'es' ? 'Ej: Copa América 2026' : 'e.g.: Copa America 2026';
  static String get torneoCreado =>
      idioma == 'es'
          ? '✅ Nuevo torneo creado. ¡A jugar!'
          : '✅ New tournament created. Let\'s play!';
  static String get historialTorneos =>
      idioma == 'es' ? 'HISTORIAL DE TORNEOS' : 'TOURNAMENT HISTORY';
  static String get sinTorneosArchivados =>
      idioma == 'es'
          ? 'Aún no hay torneos archivados'
          : 'No archived tournaments yet';
  static String get rankingFinal =>
      idioma == 'es' ? 'Ranking Final' : 'Final Ranking';
  static String get torneoActivo =>
      idioma == 'es' ? 'Torneo activo' : 'Active tournament';
  static String get crearTorneo =>
      idioma == 'es' ? 'Crear torneo' : 'Create tournament';
  static String get advertenciaNuevoTorneo =>
      idioma == 'es'
          ? 'Se guardarán los puntos actuales y comenzará un torneo nuevo. Los jugadores se conservan con 0 puntos.'
          : 'Current points will be saved and a new tournament will begin. Players are kept with 0 points.';
}
