import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_strings.dart';
import 'premium_service.dart';

class AppSettings extends ChangeNotifier {
  static final AppSettings instance = AppSettings._init();
  AppSettings._init();

  static const String _keyIdioma = 'idioma';
  static const String _keyGameMode = 'game_mode';
  static const String _keyPuntosExacto = 'puntos_exacto';
  static const String _keyPuntosGanador = 'puntos_ganador';
  static const String _keyChampion = 'champion_team';
  static const String _keyPuntosChampion = 'puntos_champion';

  String _idioma = 'es';
  String _gameMode = 'clasico';
  int _puntosExacto = 3;
  int _puntosGanador = 1;
  String _champion = ''; // equipo campeón declarado
  int _puntosChampion = 10;

  String get idioma => _idioma;
  String get gameMode => _gameMode;
  int get puntosExacto => _puntosExacto; // ← NUEVO
  int get puntosGanador => _puntosGanador;
  String get champion => _champion;
  int get puntosChampion => _puntosChampion;
  bool get championDeclarado => _champion.isNotEmpty;

  // Cambiar idioma y guardar
  Future<void> cambiarIdioma(String nuevoIdioma) async {
    if (_idioma == nuevoIdioma) return;
    _idioma = nuevoIdioma;
    AppStrings.idioma = nuevoIdioma;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyIdioma, nuevoIdioma);
    notifyListeners();
  }

  Future<void> cargarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    _idioma = prefs.getString(_keyIdioma) ?? 'es';
    _gameMode = prefs.getString(_keyGameMode) ?? 'clasico';
    _puntosExacto = prefs.getInt(_keyPuntosExacto) ?? 3;
    _puntosGanador = prefs.getInt(_keyPuntosGanador) ?? 1;
    AppStrings.idioma = _idioma;
    await PremiumService.instance.inicializar();
    _champion       = prefs.getString(_keyChampion)      ?? '';
_puntosChampion = prefs.getInt(_keyPuntosChampion)   ?? 10;
  }

  //Cambiar modo de juego de puntos ganados
  Future<void> cambiarModoJuego(String nuevoModo) async {
    if (_gameMode == nuevoModo) return;
    _gameMode = nuevoModo;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyGameMode, nuevoModo);
    notifyListeners();
  }

  Future<void> cambiarPuntosPersonalizados(int exacto, int ganador) async {
    _puntosExacto = exacto;
    _puntosGanador = ganador;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPuntosExacto, exacto);
    await prefs.setInt(_keyPuntosGanador, ganador);
    notifyListeners();
  }

  Future<void> cambiarPuntosChampion(int puntos) async {
  _puntosChampion = puntos;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_keyPuntosChampion, puntos);
  notifyListeners();
}

Future<void> declararCampeon(String equipo) async {
  _champion = equipo;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_keyChampion, equipo);
  notifyListeners();
}

Future<void> resetearCampeon() async {
  _champion = '';
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_keyChampion);
  notifyListeners();
}
}
