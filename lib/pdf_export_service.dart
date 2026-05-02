// lib/pdf_export_service.dart
//
// Genera un PDF del ranking completo y lo comparte usando share_plus.
// Solo se llama desde main.dart cuando el usuario es Premium.
//
// REQUIERE en pubspec.yaml:
//   pdf: ^3.11.1
// Luego ejecutar: flutter pub get

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'database_helper.dart';
import 'app_strings.dart'; // ← usamos AppStrings.idioma, NO AppSettings

class PdfExportService {
  // ── Colores ───────────────────────────────────────────────────────────────
  static const PdfColor _gold = PdfColor.fromInt(0xFFD4AF37);
  static const PdfColor _silver = PdfColor.fromInt(0xFFA8A9AD);
  static const PdfColor _bronze = PdfColor.fromInt(0xFFCD7F32);
  static const PdfColor _dark = PdfColor.fromInt(0xFF0A1628);
  static const PdfColor _accent = PdfColor.fromInt(0xFF1A73E8);
  static const PdfColor _white = PdfColor.fromInt(0xFFFFFFFF);
  static const PdfColor _light = PdfColor.fromInt(0xFFF5F7FA);
  static const PdfColor _rowAlt = PdfColor.fromInt(0xFFEDF2FB);
  static const PdfColor _red = PdfColor.fromInt(0xFFE74C3C);

  /// Punto de entrada único.
  /// Llámalo así desde main.dart:
  ///   await PdfExportService.exportar(context);
  static Future<void> exportar(BuildContext context) async {
    final db = DatabaseHelper.instance;
    final lang = AppStrings.idioma; // 'es' o 'en'

    // ── 1. Leer datos de la base de datos ─────────────────────────────────
    final torneoInfo = await db.getTournamentActivo();
    final nombreTorneo = torneoInfo?['name'] as String? ?? 'Mundial 2026';
    final matchStats = await db.getMatchStats();
    final jugados = matchStats['jugados'] ?? 0;
    final totalPartidos = matchStats['total'] ?? 0;

    // getEstadisticasJugadores() ya viene ordenado por puntos DESC
    // y trae: id, name, points, exactos, ganadores, fallos, total, precision
    final stats = await db.getEstadisticasJugadores();

    // Apuestas al campeón — columna 'team' en la DB
    final rawDb = await db.database;
    final torneoId = await db.getTournamentActivoId();
    final championBets = await rawDb.rawQuery(
      '''
      SELECT cb.team, p.name AS player_name
      FROM champion_bets cb
      JOIN participants p ON cb.participant_id = p.id
      WHERE cb.tournament_id = ?
    ''',
      [torneoId],
    );

    // ── 2. Construir el PDF ───────────────────────────────────────────────
    final pdf = pw.Document(title: nombreTorneo);
    final bold = pw.Font.helveticaBold();
    final reg = pw.Font.helvetica();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 36),
        theme: pw.ThemeData.withFont(base: reg, bold: bold),
        build: (ctx) => [
          _header(nombreTorneo, lang, bold, reg),
          pw.SizedBox(height: 14),
          _resumenCards(jugados, totalPartidos, stats.length, lang, bold, reg),
          pw.SizedBox(height: 18),
          _seccionTitulo(lang == 'es' ? 'RANKING' : 'RANKINGS', bold),
          pw.SizedBox(height: 8),
          _tablaRanking(stats, championBets, lang, bold, reg),
          if (stats.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            _seccionTitulo(lang == 'es' ? 'ESTADÍSTICAS' : 'STATISTICS', bold),
            pw.SizedBox(height: 8),
            _tablaEstadisticas(stats, lang, bold, reg),
          ],
          if (championBets.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            _seccionTitulo(
              lang == 'es' ? 'APUESTAS AL CAMPEÓN' : 'CHAMPION BETS',
              bold,
            ),
            pw.SizedBox(height: 8),
            _chipsCampeon(championBets, reg),
          ],
          pw.SizedBox(height: 24),
          _footer(lang, reg),
        ],
      ),
    );

    // ── 3. Guardar y compartir ────────────────────────────────────────────
    final bytes = await pdf.save();
    await _compartir(bytes, nombreTorneo);
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  static pw.Widget _header(
    String titulo,
    String lang,
    pw.Font bold,
    pw.Font reg,
  ) {
    final now = DateTime.now();
    final fecha =
        '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year}';
    final subtitulo = lang == 'es'
        ? 'Copa del Mundo 2026 · USA · CAN · MEX'
        : 'World Cup 2026 · USA · CAN · MEX';

    return pw.Container(
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [_dark, _accent],
          begin: pw.Alignment.centerLeft,
          end: pw.Alignment.centerRight,
        ),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                titulo,
                style: pw.TextStyle(font: bold, fontSize: 17, color: _white),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                subtitulo,
                style: pw.TextStyle(font: reg, fontSize: 10, color: _gold),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                lang == 'es' ? 'Ranking Oficial' : 'Official Rankings',
                style: pw.TextStyle(font: bold, fontSize: 11, color: _white),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                fecha,
                style: pw.TextStyle(font: reg, fontSize: 9, color: _silver),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Cards de resumen ────────────────────────────────────────────────────────
  static pw.Widget _resumenCards(
    int jugados,
    int total,
    int numJugadores,
    String lang,
    pw.Font bold,
    pw.Font reg,
  ) {
    final progreso = total > 0
        ? '${((jugados / total) * 100).toStringAsFixed(0)}%'
        : '0%';

    return pw.Row(
      children: [
        _card(
          numJugadores.toString(),
          lang == 'es' ? 'Jugadores' : 'Players',
          _accent,
          bold,
          reg,
        ),
        pw.SizedBox(width: 8),
        _card(
          '$jugados / $total',
          lang == 'es' ? 'Partidos jugados' : 'Matches played',
          _dark,
          bold,
          reg,
        ),
        pw.SizedBox(width: 8),
        _card(
          progreso,
          lang == 'es' ? 'Progreso' : 'Progress',
          _gold,
          bold,
          reg,
        ),
      ],
    );
  }

  static pw.Widget _card(
    String valor,
    String etiqueta,
    PdfColor color,
    pw.Font bold,
    pw.Font reg,
  ) {
    return pw.Expanded(
      child: pw.Container(
        decoration: pw.BoxDecoration(
          color: color,
          borderRadius: pw.BorderRadius.circular(6),
        ),
        padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              valor,
              style: pw.TextStyle(font: bold, fontSize: 15, color: _white),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              etiqueta,
              style: pw.TextStyle(font: reg, fontSize: 8, color: _white),
            ),
          ],
        ),
      ),
    );
  }

  // ── Título de sección ───────────────────────────────────────────────────────
  static pw.Widget _seccionTitulo(String texto, pw.Font bold) {
    return pw.Row(
      children: [
        pw.Container(width: 4, height: 16, color: _accent),
        pw.SizedBox(width: 8),
        pw.Text(
          texto,
          style: pw.TextStyle(font: bold, fontSize: 12, color: _dark),
        ),
      ],
    );
  }

  // ── Tabla de ranking ────────────────────────────────────────────────────────
  static pw.Widget _tablaRanking(
    List<Map<String, dynamic>> stats,
    List<Map<String, dynamic>> championBets,
    String lang,
    pw.Font bold,
    pw.Font reg,
  ) {
    final filaHeader = pw.TableRow(
      decoration: const pw.BoxDecoration(color: _dark),
      children: [
        _celda('#', bold, esHeader: true),
        _celda(lang == 'es' ? 'Jugador' : 'Player', bold, esHeader: true),
        _celda('Pts', bold, esHeader: true),
        _celda(lang == 'es' ? 'Campeón' : 'Champion', bold, esHeader: true),
      ],
    );

    final filas = stats.asMap().entries.map((e) {
      final i = e.key;
      final j = e.value;
      final pos = i + 1;

      // Buscar apuesta al campeón de este jugador por nombre
      final bet = championBets.firstWhere(
        (b) => b['player_name'] == j['name'],
        orElse: () => {},
      );
      final equipo = bet.isNotEmpty ? (bet['team'] as String? ?? '—') : '—';

      final colorPos = pos == 1
          ? _gold
          : pos == 2
          ? _silver
          : pos == 3
          ? _bronze
          : _dark;
      final bg = i.isEven ? _light : _rowAlt;

      return pw.TableRow(
        decoration: pw.BoxDecoration(color: bg),
        children: [
          _celdaColor('$pos', colorPos, bold),
          _celda(j['name'] as String, reg),
          _celda((j['points'] as int).toString(), bold),
          _celda(equipo, reg, fontSize: 9),
        ],
      );
    }).toList();

    return pw.Table(
      columnWidths: {
        0: const pw.FixedColumnWidth(28),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FixedColumnWidth(52),
        3: const pw.FlexColumnWidth(2),
      },
      border: pw.TableBorder.all(
        color: PdfColor.fromInt(0xFFDDE3EA),
        width: 0.5,
      ),
      children: [filaHeader, ...filas],
    );
  }

  // ── Tabla de estadísticas ───────────────────────────────────────────────────
  // Usa directamente getEstadisticasJugadores() que ya calculó todo.
  static pw.Widget _tablaEstadisticas(
    List<Map<String, dynamic>> stats,
    String lang,
    pw.Font bold,
    pw.Font reg,
  ) {
    final header = pw.TableRow(
      decoration: const pw.BoxDecoration(color: _dark),
      children: [
        _celda(lang == 'es' ? 'Jugador' : 'Player', bold, esHeader: true),
        _celda(lang == 'es' ? 'Exactos' : 'Exact', bold, esHeader: true),
        _celda(lang == 'es' ? 'Ganadores' : 'Winners', bold, esHeader: true),
        _celda(lang == 'es' ? 'Fallos' : 'Wrong', bold, esHeader: true),
        _celda(lang == 'es' ? 'Precisión' : 'Accuracy', bold, esHeader: true),
      ],
    );

    final filas = stats.asMap().entries.map((e) {
      final i = e.key;
      final j = e.value;
      final bg = i.isEven ? _light : _rowAlt;

      return pw.TableRow(
        decoration: pw.BoxDecoration(color: bg),
        children: [
          _celda(j['name'] as String, reg),
          _celdaColor(j['exactos'].toString(), _gold, bold),
          _celdaColor(j['ganadores'].toString(), _accent, bold),
          _celdaColor(j['fallos'].toString(), _red, bold),
          _celda('${j["precision"]}%', reg),
        ],
      );
    }).toList();

    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(2.5),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1),
      },
      border: pw.TableBorder.all(
        color: PdfColor.fromInt(0xFFDDE3EA),
        width: 0.5,
      ),
      children: [header, ...filas],
    );
  }

  // ── Chips de apuestas al campeón ────────────────────────────────────────────
  static pw.Widget _chipsCampeon(List<Map<String, dynamic>> bets, pw.Font reg) {
    // Agrupar por equipo y contar cuántos apostaron a cada uno
    final conteo = <String, int>{};
    for (final b in bets) {
      final t = b['team'] as String? ?? '—';
      conteo[t] = (conteo[t] ?? 0) + 1;
    }
    final ordenados = conteo.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return pw.Wrap(
      spacing: 8,
      runSpacing: 6,
      children: ordenados.map((e) {
        return pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: pw.BoxDecoration(
            color: _dark,
            borderRadius: pw.BorderRadius.circular(20),
          ),
          child: pw.Text(
            '${e.key}  x${e.value}',
            style: pw.TextStyle(font: reg, fontSize: 9, color: _white),
          ),
        );
      }).toList(),
    );
  }

  // ── Footer ──────────────────────────────────────────────────────────────────
  static pw.Widget _footer(String lang, pw.Font reg) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _silver, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Crack Mundial 2026',
            style: pw.TextStyle(font: reg, fontSize: 8, color: _silver),
          ),
          pw.Text(
            lang == 'es'
                ? 'Generado con Crack Mundial 2026'
                : 'Generated with Crack Mundial 2026',
            style: pw.TextStyle(font: reg, fontSize: 8, color: _silver),
          ),
        ],
      ),
    );
  }

  // ── Helpers de celda ────────────────────────────────────────────────────────
  static pw.Widget _celda(
    String texto,
    pw.Font font, {
    bool esHeader = false,
    double fontSize = 10,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        texto,
        style: pw.TextStyle(
          font: font,
          fontSize: esHeader ? 9 : fontSize,
          color: esHeader ? _white : _dark,
        ),
      ),
    );
  }

  static pw.Widget _celdaColor(String texto, PdfColor color, pw.Font bold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        texto,
        style: pw.TextStyle(font: bold, fontSize: 11, color: color),
      ),
    );
  }

  // ── Guardar archivo y abrir el diálogo de compartir ─────────────────────────
  static Future<void> _compartir(Uint8List bytes, String titulo) async {
    final dir = await getTemporaryDirectory();
    final slug = titulo.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final file = File('${dir.path}/$slug.pdf');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([
      XFile(file.path, mimeType: 'application/pdf'),
    ], subject: titulo);
  }
}
