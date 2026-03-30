class AdHelper {
  // ── BANNER ────────────────────────────────────────────────────────────
  static String get bannerAdUnitId {
    // Mientras desarrollas, usa siempre los IDs de prueba de Google.
    // Cuando vayas a publicar, reemplaza por tus IDs reales.
    return 'ca-app-pub-3940256099942544/6300978111'; // TEST Android
    // iOS test: 'ca-app-pub-3940256099942544/2934735716'
  }

  // ── INTERSTITIAL ──────────────────────────────────────────────────────
  static String get interstitialAdUnitId {
    return 'ca-app-pub-3940256099942544/1033173712'; // TEST Android
    // iOS test: 'ca-app-pub-3940256099942544/4411468910'
  }
}