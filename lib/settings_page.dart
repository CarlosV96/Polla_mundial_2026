import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_settings.dart';
import 'app_strings.dart';
import 'premium_service.dart';
import 'premium_gate.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _idiomaSeleccionado = AppSettings.instance.idioma;
  String _modoJuegoSeleccionado = AppSettings.instance.gameMode;
  int _puntosExacto = AppSettings.instance.puntosExacto;
  int _puntosGanador = AppSettings.instance.puntosGanador;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoPrincipal,
      appBar: AppBar(
        title: Text(AppStrings.configuracion),
        backgroundColor: AppColors.fondoPrincipal,
        iconTheme: const IconThemeData(color: AppColors.dorado),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0F2E), Color(0xFF0D1333), Color(0xFF0A0F2E)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── SECCIÓN IDIOMA ───────────────────────────────────────
            _seccionTitulo("🌐  ${AppStrings.idiomaTitulo}"),

            const SizedBox(height: 10),

            _opcionIdioma(bandera: "🇨🇴", nombre: "Español", codigo: "es"),

            const SizedBox(height: 8),

            _opcionIdioma(bandera: "🇺🇸", nombre: "English", codigo: "en"),

            const SizedBox(height: 28),

            // ── SECCIÓN MODO DE JUEGO ────────────────────────────────────────────
            _seccionTitulo("🎮  ${AppStrings.modoJuego}"),

            const SizedBox(height: 4),

            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                AppStrings.modoJuegoDesc,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textoGris,
                ),
              ),
            ),

            _opcionModo(
              icono: Icons.emoji_events_outlined,
              nombre: AppStrings.modoClasico,
              descripcion: AppStrings.modoClasicoDesc,
              codigo: 'clasico',
              premium: false,
            ),

            const SizedBox(height: 8),

            _opcionModo(
              icono: Icons.gps_fixed,
              nombre: AppStrings.modoExacto,
              descripcion: AppStrings.modoExactoDesc,
              codigo: 'exacto',
              premium: true,
            ),

            const SizedBox(height: 28),

            // Modo Personalizado — premium
            _opcionModo(
              icono: Icons.tune,
              nombre: AppStrings.modoPersonalizado,
              descripcion: AppStrings.modoPersonalizadoDesc,
              codigo: 'personalizado',
              premium: true,
            ),

            // ── PANEL PERSONALIZADO (solo visible si está seleccionado) ──
            if (_modoJuegoSeleccionado == 'personalizado' &&
                PremiumService.instance.isPremium)
              _panelPersonalizado(),

            const SizedBox(height: 28),

            // ── SECCIÓN ACERCA DE ────────────────────────────────────
            _seccionTitulo("ℹ️  ${AppStrings.acercaDe}"),

            const SizedBox(height: 10),

            _itemInfo(
              icono: Icons.info_outline,
              titulo: AppStrings.version,
              valor: "1.0.0",
            ),

            const SizedBox(height: 8),

            _itemInfo(
              icono: Icons.favorite_outline,
              titulo: AppStrings.acercaDe,
              valor: AppStrings.acercaDeDesc,
            ),

            const SizedBox(height: 8),

            _itemInfo(
              icono: Icons.sports_soccer,
              titulo: "Mundial",
              valor: "FIFA World Cup 2026 🏆",
            ),
          ],
        ),
      ),
    );
  }

  Widget _panelPersonalizado() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.fondoTarjeta,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.acento.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Pts exacto
          _filaPuntos(
            label: AppStrings.puntosExactoLabel,
            valor: _puntosExacto,
            min: 1,
            max: 10,
            onCambio: (v) async {
              setState(() => _puntosExacto = v);
              await AppSettings.instance.cambiarPuntosPersonalizados(
                v,
                _puntosGanador,
              );
            },
          ),

          const SizedBox(height: 14),

          Divider(color: AppColors.dorado.withOpacity(0.1)),

          const SizedBox(height: 14),

          // Pts ganador
          _filaPuntos(
            label: AppStrings.puntosGanadorLabel,
            valor: _puntosGanador,
            min: 0,
            max: 5,
            onCambio: (v) async {
              setState(() => _puntosGanador = v);
              await AppSettings.instance.cambiarPuntosPersonalizados(
                _puntosExacto,
                v,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _filaPuntos({
    required String label,
    required int valor,
    required int min,
    required int max,
    required Function(int) onCambio,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textoBlanco),
        ),
        Row(
          children: [
            _botonPunto(
              icono: Icons.remove,
              onTap: valor > min ? () => onCambio(valor - 1) : null,
            ),
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(
                '$valor',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dorado,
                ),
              ),
            ),
            _botonPunto(
              icono: Icons.add,
              onTap: valor < max ? () => onCambio(valor + 1) : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _botonPunto({required IconData icono, VoidCallback? onTap}) {
    final activo = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.dorado.withOpacity(activo ? 0.12 : 0.04),
          border: Border.all(
            color: AppColors.dorado.withOpacity(activo ? 0.4 : 0.1),
          ),
        ),
        child: Icon(
          icono,
          color: AppColors.dorado.withOpacity(activo ? 1.0 : 0.3),
          size: 16,
        ),
      ),
    );
  }

  Widget _seccionTitulo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.textoGris,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _opcionIdioma({
    required String bandera,
    required String nombre,
    required String codigo,
  }) {
    final seleccionado = _idiomaSeleccionado == codigo;

    return GestureDetector(
      onTap: () async {
        await AppSettings.instance.cambiarIdioma(codigo);
        setState(() => _idiomaSeleccionado = codigo);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: seleccionado
              ? AppColors.dorado.withOpacity(0.12)
              : AppColors.fondoTarjeta,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: seleccionado
                ? AppColors.dorado.withOpacity(0.6)
                : AppColors.dorado.withOpacity(0.15),
            width: seleccionado ? 1.5 : 1,
          ),
          boxShadow: seleccionado
              ? [
                  BoxShadow(
                    color: AppColors.dorado.withOpacity(0.12),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(bandera, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 14),
            Text(
              nombre,
              style: TextStyle(
                fontSize: 15,
                fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
                color: seleccionado ? AppColors.dorado : AppColors.textoBlanco,
              ),
            ),
            const Spacer(),
            if (seleccionado)
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.dorado.withOpacity(0.2),
                  border: Border.all(color: AppColors.dorado.withOpacity(0.6)),
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.dorado,
                  size: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Opción de modo ────────────────────────────────────────────────────────
  Widget _opcionModo({
    required IconData icono,
    required String nombre,
    required String descripcion,
    required String codigo,
    required bool premium,
  }) {
    final seleccionado = _modoJuegoSeleccionado == codigo;
    final isPremium = PremiumService.instance.isPremium;
    final bloqueado = premium && !isPremium;

    final widget = GestureDetector(
      onTap: bloqueado
          ? null
          : () async {
              await AppSettings.instance.cambiarModoJuego(codigo);
              setState(() => _modoJuegoSeleccionado = codigo);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: seleccionado
              ? AppColors.acento.withOpacity(0.10)
              : AppColors.fondoTarjeta,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: seleccionado
                ? AppColors.acento.withOpacity(0.6)
                : AppColors.dorado.withOpacity(0.15),
            width: seleccionado ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icono,
              color: bloqueado
                  ? AppColors.textoGris.withOpacity(0.4)
                  : seleccionado
                  ? AppColors.acento
                  : AppColors.textoGris,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        nombre,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: seleccionado
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: bloqueado
                              ? AppColors.textoGris.withOpacity(0.4)
                              : seleccionado
                              ? AppColors.acento
                              : AppColors.textoBlanco,
                        ),
                      ),
                      if (bloqueado) ...[
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.soloPremium,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.dorado,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    descripcion,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textoGris.withOpacity(
                        bloqueado ? 0.4 : 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (seleccionado)
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.acento.withOpacity(0.2),
                  border: Border.all(color: AppColors.acento.withOpacity(0.6)),
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.acento,
                  size: 14,
                ),
              ),
            if (bloqueado)
              const Icon(Icons.lock_outline, color: AppColors.dorado, size: 16),
          ],
        ),
      ),
    );

    // Si está bloqueado, envuelve con PremiumGate para abrir el paywall
    return bloqueado ? PremiumGate(child: widget) : widget;
  }

  Widget _itemInfo({
    required IconData icono,
    required String titulo,
    required String valor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.fondoTarjeta,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dorado.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(icono, color: AppColors.textoGris, size: 20),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textoBlanco,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textoGris,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
