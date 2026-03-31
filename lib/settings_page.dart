import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_settings.dart';
import 'app_strings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _idiomaSeleccionado = AppSettings.instance.idioma;

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

            _opcionIdioma(
              bandera: "🇨🇴",
              nombre: "Español",
              codigo: "es",
            ),

            const SizedBox(height: 8),

            _opcionIdioma(
              bandera: "🇺🇸",
              nombre: "English",
              codigo: "en",
            ),

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
                fontWeight: seleccionado
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: seleccionado
                    ? AppColors.dorado
                    : AppColors.textoBlanco,
              ),
            ),
            const Spacer(),
            if (seleccionado)
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.dorado.withOpacity(0.2),
                  border: Border.all(
                    color: AppColors.dorado.withOpacity(0.6),
                  ),
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
        border: Border.all(
          color: AppColors.dorado.withOpacity(0.15),
        ),
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