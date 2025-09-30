import 'package:flutter_test/flutter_test.dart';
import 'package:smart_login/services/api_service.dart';

void main() {
  group('ApiService URL Tests', () {
    test('BaseURL debe estar configurada correctamente', () {
      const expectedBaseUrl =
          'https://smart-condominium-backend-cg7l.onrender.com';
      expect(ApiService.baseUrl, expectedBaseUrl);
    });

    test('URLs deben construirse correctamente', () {
      // Test de URL de login debe tener el formato correcto
      // Esta prueba verifica que las URLs se construyen sin errores
      expect(
        () => Uri.parse('${ApiService.baseUrl}/api/login/'),
        returnsNormally,
      );

      // Test de URLs de finanzas
      expect(
        () => Uri.parse('${ApiService.baseUrl}/api/finanzas/gastos/'),
        returnsNormally,
      );

      // Test de URLs con parámetros
      const gastoId = 123;
      final urlPagarGasto =
          '${ApiService.baseUrl}/api/finanzas/gastos/$gastoId/pagar/';
      expect(() => Uri.parse(urlPagarGasto), returnsNormally);

      // Verificar que no haya dobles slashes
      expect(
        urlPagarGasto.contains('//'),
        isFalse,
        reason: 'URL no debe contener dobles slashes',
      );
    });

    test('BaseURL debe ser una URL válida', () {
      final uri = Uri.parse(ApiService.baseUrl);
      expect(uri.scheme, 'https');
      expect(uri.host, 'smart-condominium-backend-cg7l.onrender.com');
    });
  });
}
