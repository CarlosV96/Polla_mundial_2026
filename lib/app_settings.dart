import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_strings.dart';

class AppSettings extends ChangeNotifier {
  static final AppSettings instance = AppSettings._init();
  AppSettings._init();

  static const String _keyIdioma = 'idioma';
  static const String _keyGameMode  = 'game_mode';

  String _idioma = 'es';
  String _gameMode  = 'clasico';                   // ← NUEVO

  String get idioma   => _idioma;
  String get gameMode => _gameMode;

  // Cargar idioma guardado al iniciar la app
  Future<void> cargarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    _idioma = prefs.getString(_keyIdioma) ?? 'es';
    AppStrings.idioma = _idioma;
  }

  // Cambiar idioma y guardar
  Future<void> cambiarIdioma(String nuevoIdioma) async {
    if (_idioma == nuevoIdioma) return;
    _idioma = nuevoIdioma;
    AppStrings.idioma = nuevoIdioma;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyIdioma, nuevoIdioma);
    notifyListeners(); // Reconstruye toda la app
  }

  //Cambiar modo de juego de puntos ganados
  Future<void> cambiarModoJuego(String nuevoModo) async {
    if (_gameMode == nuevoModo) return;
    _gameMode = nuevoModo;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyGameMode, nuevoModo);
    notifyListeners();
  }
}