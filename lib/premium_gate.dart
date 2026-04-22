import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_strings.dart';
import 'premium_service.dart';

/// Uso:
/// PremiumGate(
///   child: BotonJugadoresIlimitados(),
/// )
class PremiumGate extends StatelessWidget {
  final Widget child;
  final String? mensajePersonalizado;

  const PremiumGate({
    super.key,
    required this.child,
    this.mensajePersonalizado,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PremiumService.instance,
      builder: (context, _) {
        if (PremiumService.instance.isPremium) {
          return child;   // ← usuario premium: acceso directo
        }

        // Usuario free: envuelve el child con un GestureDetector que muestra el paywall
        return GestureDetector(
          onTap: () => _mostrarPaywall(context),
          child: Stack(
            children: [
              // El widget original pero oscurecido
              Opacity(opacity: 0.4, child: child),

              // Candado encima
              Positioned.fill(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.fondoPrincipal.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.dorado.withOpacity(0.6),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          color: AppColors.dorado,
                          size: 13,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Premium',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.dorado,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Paywall bottom sheet ──────────────────────────────────────────────────
  void _mostrarPaywall(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PaywallSheet(),
    );
  }
}

// ── Paywall Sheet ─────────────────────────────────────────────────────────────
class PaywallSheet extends StatefulWidget {
  const PaywallSheet({super.key});

  @override
  State<PaywallSheet> createState() => _PaywallSheetState();
}

class _PaywallSheetState extends State<PaywallSheet> {
  @override
  Widget build(BuildContext context) {
    final svc = PremiumService.instance;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D1333), Color(0xFF0A0F2E)],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.dorado.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: ListenableBuilder(
        listenable: svc,
        builder: (context, _) {
          // ── Si se activó premium: cierra automáticamente ──────────────
          if (svc.isPremium) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppStrings.premiumActivado)),
              );
            });
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.dorado.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 20),

              // Trofeo
              Image.asset(
                'assets/images/trophy.png',
                width: 70,
                height: 70,
              ),

              const SizedBox(height: 12),

              // Título
              Text(
                AppStrings.premiumTitulo,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dorado,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                AppStrings.premiumSubtitulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textoGris,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              // Lista de beneficios
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.fondoTarjeta,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.dorado.withOpacity(0.15),
                  ),
                ),
                child: Column(
                  children: AppStrings.premiumBeneficios
                      .map(
                        (b) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Text(b, style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Precio
              Text(
                svc.producto?.price ?? '\$2.99',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dorado,
                ),
              ),
              Text(
                AppStrings.premiumPrecio,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textoGris,
                ),
              ),

              const SizedBox(height: 20),

              // Botón comprar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: svc.cargando
                      ? null
                      : () async {
                          final ok = await svc.comprar();
                          if (!ok && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppStrings.premiumError),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dorado,
                    foregroundColor: AppColors.fondoPrincipal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: svc.cargando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.fondoPrincipal,
                          ),
                        )
                      : Text(
                          AppStrings.premiumBoton,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // Restaurar compra
              TextButton(
                onPressed: svc.cargando ? null : () => svc.restaurar(),
                child: Text(
                  AppStrings.premiumRestaurar,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textoGris,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}