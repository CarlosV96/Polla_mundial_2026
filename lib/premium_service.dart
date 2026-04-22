import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumService extends ChangeNotifier {
  static final PremiumService instance = PremiumService._init();
  PremiumService._init();

  // ── Constantes ────────────────────────────────────────────────────────────
  static const String kProductId   = 'premium_polla_mundial';
  static const String kPrefKey     = 'is_premium';

  // ── Estado ────────────────────────────────────────────────────────────────
  bool _isPremium      = false;
  bool _disponible     = false;   // ¿Google Play disponible?
  bool _cargando       = false;   // ¿Procesando una compra?
  ProductDetails? _producto;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  bool get isPremium   => _isPremium;
  bool get cargando    => _cargando;
  ProductDetails? get producto => _producto;

  // ── Inicializar ───────────────────────────────────────────────────────────
  Future<void> inicializar() async {
    // 1. Leer estado guardado localmente
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(kPrefKey) ?? false;

    // 2. Verificar si Google Play está disponible
    _disponible = await InAppPurchase.instance.isAvailable();
    if (!_disponible) {
      notifyListeners();
      return;
    }

    // 3. Escuchar el stream de compras (pagos completados, restaurados, etc.)
    _sub = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (e) => debugPrint('❌ Error stream compras: $e'),
    );

    // 4. Cargar info del producto desde Google Play
    await _cargarProducto();

    notifyListeners();
  }

  // ── Cargar producto desde Play Store ─────────────────────────────────────
  Future<void> _cargarProducto() async {
    final response = await InAppPurchase.instance.queryProductDetails(
      {kProductId},
    );

    if (response.error != null) {
      debugPrint('❌ Error cargando producto: ${response.error}');
      return;
    }

    if (response.productDetails.isEmpty) {
      debugPrint('⚠️ Producto no encontrado en Play Store: $kProductId');
      return;
    }

    _producto = response.productDetails.first;
    debugPrint('✅ Producto cargado: ${_producto!.title} — ${_producto!.price}');
    notifyListeners();
  }

  // ── Iniciar compra ────────────────────────────────────────────────────────
  Future<bool> comprar() async {
    if (!_disponible) {
      debugPrint('⚠️ Google Play no disponible');
      return false;
    }

    if (_producto == null) {
      await _cargarProducto();
      if (_producto == null) return false;
    }

    _cargando = true;
    notifyListeners();

    final param = PurchaseParam(productDetails: _producto!);
    try {
      return await InAppPurchase.instance.buyNonConsumable(
        purchaseParam: param,
      );
    } catch (e) {
      debugPrint('❌ Error al iniciar compra: $e');
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  // ── Restaurar compras (si el usuario reinstala la app) ────────────────────
  Future<void> restaurar() async {
    if (!_disponible) return;
    _cargando = true;
    notifyListeners();
    await InAppPurchase.instance.restorePurchases();
  }

  // ── Procesar actualizaciones del stream ───────────────────────────────────
  Future<void> _onPurchaseUpdate(List<PurchaseDetails> compras) async {
    for (final compra in compras) {
      if (compra.productID != kProductId) continue;

      switch (compra.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _activarPremium();
          await InAppPurchase.instance.completePurchase(compra);
          break;

        case PurchaseStatus.error:
          debugPrint('❌ Error en compra: ${compra.error}');
          _cargando = false;
          notifyListeners();
          break;

        case PurchaseStatus.canceled:
          _cargando = false;
          notifyListeners();
          break;

        case PurchaseStatus.pending:
          debugPrint('⏳ Compra pendiente...');
          break;
      }
    }
  }

  // ── Activar premium y persistir ───────────────────────────────────────────
  Future<void> _activarPremium() async {
    _isPremium = true;
    _cargando  = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kPrefKey, true);
    debugPrint('🏆 ¡Premium activado!');
    notifyListeners();
  }

  // ── Solo para pruebas en desarrollo ───────────────────────────────────────
  Future<void> activarPremiumDebug() async {
    await _activarPremium();
  }

  Future<void> desactivarPremiumDebug() async {
    _isPremium = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kPrefKey, false);
    notifyListeners();
  }

  // ── Limpiar ───────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}