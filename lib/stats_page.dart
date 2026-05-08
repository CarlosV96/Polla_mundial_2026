import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'app_colors.dart';
import 'app_strings.dart';
import 'database_helper.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoPrincipal,
      appBar: AppBar(
        title: Text(AppStrings.estadisticasTorneo),
        backgroundColor: AppColors.fondoPrincipal,
        iconTheme: const IconThemeData(color: AppColors.dorado),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          indicatorColor: AppColors.dorado,
          labelColor: AppColors.dorado,
          unselectedLabelColor: AppColors.textoGris,
          tabs: [
            Tab(text: AppStrings.puntosJugadores),
            Tab(text: AppStrings.distribucionApuestas),
            Tab(text: AppStrings.resumenJugadores),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0F2E), Color(0xFF0D1333), Color(0xFF0A0F2E)],
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: DatabaseHelper.instance.getEstadisticasJugadores(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.dorado),
              );
            }

            final data = snapshot.data!;
            final tieneDatos = data.any((j) => (j['total'] as int) > 0);

            if (!tieneDatos) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart_outlined,
                      size: 60,
                      color: AppColors.textoGris.withOpacity(0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.sinDatosEstadisticas,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textoGris,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              );
            }

            return TabBarView(
              controller: _tabCtrl,
              children: [
                _TabPuntos(data: data),
                _TabDistribucion(data: data),
                _TabResumen(data: data),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Tab 1: Gráfica de barras — puntos por jugador ─────────────────────────────
class _TabPuntos extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _TabPuntos({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxPts = data
        .map((j) => (j['points'] as int).toDouble())
        .fold(0.0, (a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            AppStrings.puntosJugadores,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.dorado,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 280,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxPts + 3,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.fondoTarjeta,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final nombre = data[group.x]['name'] as String;
                      return BarTooltipItem(
                        '$nombre\n${rod.toY.toInt()} pts',
                        const TextStyle(
                          color: AppColors.dorado,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= data.length) {
                          return const SizedBox.shrink();
                        }
                        final nombre = data[index]['name'] as String;
                        final corto = nombre.length > 8
                            ? '${nombre.substring(0, 7)}.'
                            : nombre;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Transform.rotate(
                            angle: -0.5,
                            child: Text(
                              corto,
                              style: const TextStyle(
                                fontSize: 9,
                                color: AppColors.textoGris,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textoGris,
                        ),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.dorado.withOpacity(0.08),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: data.asMap().entries.map((entry) {
                  final i = entry.key;
                  final j = entry.value;
                  final pts = (j['points'] as int).toDouble();

                  // Color según posición
                  final Color color = i == 0
                      ? const Color(0xFFFFD700)
                      : i == 1
                      ? const Color(0xFFC0C0C0)
                      : i == 2
                      ? const Color(0xFFCD7F32)
                      : AppColors.acento;

                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: pts,
                        color: color,
                        width: 22,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxPts + 3,
                          color: AppColors.dorado.withOpacity(0.05),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Leyenda de posiciones
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _leyenda(const Color(0xFFFFD700), '1°'),
              const SizedBox(width: 16),
              _leyenda(const Color(0xFFC0C0C0), '2°'),
              const SizedBox(width: 16),
              _leyenda(const Color(0xFFCD7F32), '3°'),
              const SizedBox(width: 16),
              _leyenda(AppColors.acento, '4°+'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _leyenda(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textoGris),
        ),
      ],
    );
  }
}

// ── Tab 2: Gráfica de torta — distribución global ─────────────────────────────
class _TabDistribucion extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  const _TabDistribucion({required this.data});

  @override
  State<_TabDistribucion> createState() => _TabDistribucionState();
}

class _TabDistribucionState extends State<_TabDistribucion> {
  int _tocado = -1;

  @override
  Widget build(BuildContext context) {
    // Totales globales
    int totalExactos = 0;
    int totalGanadores = 0;
    int totalFallos = 0;

    for (final j in widget.data) {
      totalExactos += j['exactos'] as int;
      totalGanadores += j['ganadores'] as int;
      totalFallos += j['fallos'] as int;
    }

    final total = totalExactos + totalGanadores + totalFallos;
    if (total == 0) {
      return Center(
        child: Text(
          AppStrings.sinDatosEstadisticas,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textoGris),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            AppStrings.distribucionApuestas,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.dorado,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            height: 240,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          response == null ||
                          response.touchedSection == null) {
                        _tocado = -1;
                        return;
                      }
                      _tocado = response.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                sectionsSpace: 3,
                centerSpaceRadius: 50,
                sections: [
                  // Exactos
                  PieChartSectionData(
                    value: totalExactos.toDouble(),
                    color: const Color(0xFFFFD700),
                    title: _tocado == 0
                        ? '$totalExactos\n${AppStrings.exactosLabel}'
                        : '$totalExactos',
                    radius: _tocado == 0 ? 70 : 60,
                    titleStyle: TextStyle(
                      fontSize: _tocado == 0 ? 12 : 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.fondoPrincipal,
                    ),
                  ),
                  // Ganadores
                  PieChartSectionData(
                    value: totalGanadores.toDouble(),
                    color: AppColors.acento,
                    title: _tocado == 1
                        ? '$totalGanadores\n${AppStrings.ganadoresLabel}'
                        : '$totalGanadores',
                    radius: _tocado == 1 ? 70 : 60,
                    titleStyle: TextStyle(
                      fontSize: _tocado == 1 ? 12 : 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  // Fallos
                  PieChartSectionData(
                    value: totalFallos.toDouble(),
                    color: AppColors.rojo,
                    title: _tocado == 2
                        ? '$totalFallos\n${AppStrings.fallosLabel}'
                        : '$totalFallos',
                    radius: _tocado == 2 ? 70 : 60,
                    titleStyle: TextStyle(
                      fontSize: _tocado == 2 ? 12 : 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Leyenda
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _itemLeyenda(
                const Color(0xFFFFD700),
                AppStrings.exactosLabel,
                totalExactos,
                total,
              ),
              const SizedBox(width: 20),
              _itemLeyenda(
                AppColors.acento,
                AppStrings.ganadoresLabel,
                totalGanadores,
                total,
              ),
              const SizedBox(width: 20),
              _itemLeyenda(
                AppColors.rojo,
                AppStrings.fallosLabel,
                totalFallos,
                total,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _itemLeyenda(Color color, String label, int valor, int total) {
    final pct = (valor / total * 100).toStringAsFixed(0);
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textoGris),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          '$pct%',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ── Tab 3: Tabla resumen por jugador ──────────────────────────────────────────
class _TabResumen extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _TabResumen({required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final j = data[index];
        final puesto = index + 1;
        final nombre = j['name'] as String;
        final puntos = j['points'] as int;
        final exactos = j['exactos'] as int;
        final ganadores = j['ganadores'] as int;
        final fallos = j['fallos'] as int;
        final total = j['total'] as int;
        final precision = j['precision'] as String;

        final Color colorPuesto = puesto == 1
            ? const Color(0xFFFFD700)
            : puesto == 2
            ? const Color(0xFFC0C0C0)
            : puesto == 3
            ? const Color(0xFFCD7F32)
            : AppColors.textoGris;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.fondoTarjeta,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorPuesto.withOpacity(puesto <= 3 ? 0.4 : 0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    '$puesto.',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: colorPuesto,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      nombre,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textoBlanco,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorPuesto.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colorPuesto.withOpacity(0.4)),
                    ),
                    child: Text(
                      '$puntos pts',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colorPuesto,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Stats row
              Row(
                children: [
                  _statChip(
                    exactos.toString(),
                    AppStrings.exactosLabel,
                    const Color(0xFFFFD700),
                  ),
                  const SizedBox(width: 8),
                  _statChip(
                    ganadores.toString(),
                    AppStrings.ganadoresLabel,
                    AppColors.acento,
                  ),
                  const SizedBox(width: 8),
                  _statChip(
                    fallos.toString(),
                    AppStrings.fallosLabel,
                    AppColors.rojo,
                  ),
                  const Spacer(),
                  // Precisión
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$precision%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dorado,
                        ),
                      ),
                      Text(
                        '${AppStrings.precisionLabel} · $total ${AppStrings.apuestasLabel}',
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.textoGris,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Barra de precisión
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: total > 0 ? (exactos + ganadores) / total : 0,
                  minHeight: 5,
                  backgroundColor: AppColors.fondoPrincipal,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.dorado),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statChip(String valor, String label, Color color) {
    return Column(
      children: [
        Text(
          valor,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: AppColors.textoGris),
        ),
      ],
    );
  }
}
