# 📱 Smart Login - Aplicación de Condominio Inteligente

## 🎯 Descripción del Proyecto

**Smart Login** es una aplicación móvil multiplataforma desarrollada en Flutter para la gestión integral de condominios inteligentes. La aplicación permite a residentes y administradores gestionar pagos, visitas, avisos, reservas y servicios del condominio de manera eficiente y segura.

## 🚀 Características Principales

### ✅ **Sistema de Pagos Completamente Funcional**
- **Pagos Individuales**: Pago de gastos comunes y multas de forma individual
- **Pagos por Lotes**: Selección múltiple y pago masivo de conceptos pendientes
- **Métodos de Pago**: Efectivo, Transferencia, Tarjeta de Crédito/Débito
- **Historial Completo**: Registro detallado de todos los pagos realizados
- **Integración API**: Conexión completa con backend Django para procesamiento

### 🔐 **Autenticación Avanzada**
- **Login Tradicional**: Usuario y contraseña
- **Quick Login**: Acceso rápido con usuarios de prueba predefinidos
- **Gestión de Sesiones**: Manejo seguro de tokens JWT
- **Roles de Usuario**: Diferenciación entre residentes, administradores y personal de seguridad

### 🏠 **Gestión de Condominio**
- **Administración de Visitantes**: Registro y control de acceso
- **Avisos del Condominio**: Comunicaciones oficiales y notificaciones
- **Reservas de Áreas Comunes**: Gestión de espacios compartidos
- **Perfil de Usuario**: Información personal y configuraciones

### 📱 **Compatibilidad Multiplataforma**
- **Android**: Optimizado para dispositivos Android
- **iOS**: Soporte nativo para iPhone y iPad
- **Web**: Acceso desde navegadores web
- **Windows**: Aplicación de escritorio
- **macOS/Linux**: Soporte para sistemas Unix

## 🛠️ Arquitectura Técnica

### **Frontend (Flutter)**
```
lib/
├── main.dart                   # Punto de entrada de la aplicación
├── api/                        # Servicios de comunicación con API
│   └── api_service.dart        # Cliente HTTP principal
├── providers/                  # Gestión de estado con Provider
│   └── auth_provider.dart      # Autenticación y manejo de sesiones
├── screens/                    # Pantallas de la aplicación
│   ├── home_screen.dart        # Dashboard principal
│   ├── login_screen.dart       # Pantalla de login
│   ├── quick_login_screen.dart # Login rápido para testing
│   ├── finanzas_screen.dart    # Gestión de pagos
│   ├── avisos_screen.dart      # Avisos del condominio
│   ├── perfil_screen.dart      # Perfil de usuario
│   └── mantenimiento/          # Pantallas de mantenimiento
├── services/                   # Servicios de la aplicación
│   ├── api_service.dart        # Servicios API centralizados
│   └── endpoints.dart          # Definición de endpoints
└── widgets/                    # Componentes reutilizables
```

### **Backend Integration**
- **API Base URL**: `http://10.0.2.2:8000/api/` (Android Emulator)
- **Protocolo**: REST API con autenticación JWT
- **Formato de Datos**: JSON
- **Endpoints Principales**:
  - `/auth/login/` - Autenticación de usuarios
  - `/pagos/registrar_pago/` - Registro de pagos
  - `/gastos/` - Gestión de gastos comunes
  - `/multas/` - Gestión de multas
  - `/avisos/` - Avisos del condominio

## 💳 Sistema de Pagos

### **Funcionalidades Implementadas**

#### **1. Pagos Individuales**
```dart
Future<bool> pagarGasto(int gastoId, Map<String, dynamic> datosPago) async {
  final response = await _makeRequest(
    'POST',
    '/gastos/$gastoId/registrar_pago/',
    data: {
      'monto_pagado': datosPago['monto'],
      'metodo_pago': datosPago['metodo_pago'],
      'referencia': datosPago['referencia'],
      'fecha_pago': datosPago['fecha_pago'],
    },
  );
  return response != null;
}
```

#### **2. Pagos por Lotes**
```dart
Future<bool> pagarMultiplesGastos(
  List<int> gastosIds, 
  Map<String, dynamic> datosPago
) async {
  for (int gastoId in gastosIds) {
    final success = await pagarGasto(gastoId, datosPago);
    if (!success) return false;
  }
  return true;
}
```

#### **3. Métodos de Pago Soportados**
- **Efectivo**: Pago en oficina del condominio
- **Transferencia**: Transferencia bancaria
- **Tarjeta de Crédito**: Procesamiento con tarjeta
- **Tarjeta de Débito**: Débito directo

#### **4. Validaciones Implementadas**
- Verificación de montos válidos
- Validación de métodos de pago
- Control de referencias únicas
- Verificación de fechas

## 🔑 Sistema de Autenticación

### **Quick Login - Usuarios de Prueba**

Para facilitar las pruebas, la aplicación incluye un sistema de Quick Login con usuarios predefinidos:

#### **Usuarios Disponibles**
```dart
final Map<String, Map<String, String>> testCredentials = {
  'admin': {
    'username': 'admin',
    'password': 'adminPassword',
    'role': 'Administrador',
    'description': 'Usuario administrador del sistema'
  },
  'residente1': {
    'username': 'residente1',
    'password': 'isaelOrtiz2',
    'role': 'Residente',
    'description': 'Residente Isael Ortiz - Apto 101'
  },
  'residente2': {
    'username': 'residente2',
    'password': 'mariaGarcia3',
    'role': 'Residente',
    'description': 'Residente María García - Apto 201'
  },
  'seguridad1': {
    'username': 'seguridad1',
    'password': 'carlosLopez1',
    'role': 'Seguridad',
    'description': 'Guardia Carlos López - Turno Diurno'
  },
  // ... más usuarios
};
```

### **Roles y Permisos**

#### **👨‍💼 Administrador**
- Gestión completa del condominio
- Administración de usuarios
- Configuración del sistema
- Reportes y auditoría

#### **🏠 Residente**
- Visualización y pago de gastos comunes
- Pago de multas
- Gestión de visitas
- Reserva de áreas comunes
- Consulta de avisos

#### **🛡️ Personal de Seguridad**
- Control de acceso
- Gestión de visitantes
- Registro de incidentes
- Comunicación con residentes

## 📊 Gestión Financiera

### **Tipos de Conceptos de Pago**

#### **1. Gastos Comunes**
- Mantenimiento de áreas comunes
- Servicios públicos compartidos
- Seguridad y vigilancia
- Limpieza y jardinería
- Administración

#### **2. Multas**
- Infracciones a reglamentos
- Uso indebido de áreas comunes
- Ruidos molestos
- Incumplimiento de normas

#### **3. Conceptos Especiales**
- Mejoras al condominio
- Eventos especiales
- Reparaciones extraordinarias

### **Estados de Pago**
- **Pendiente**: Concepto generado, sin pagar
- **Pagado**: Concepto completamente pagado
- **Parcial**: Pago parcial realizado
- **Vencido**: Concepto con fecha de vencimiento superada

## 🔧 Configuración y Instalación

### **Requisitos del Sistema**
- **Flutter SDK**: 3.24.0 o superior
- **Dart SDK**: 3.5.0 o superior
- **Android Studio**: Para desarrollo Android
- **Xcode**: Para desarrollo iOS (solo macOS)
- **VS Code**: Editor recomendado

### **Instalación**

#### **1. Clonar el Repositorio**
```bash
git clone https://github.com/herlandt/smart_login.git
cd smart_login
```

#### **2. Instalar Dependencias**
```bash
flutter pub get
```

#### **3. Configurar Emulador/Dispositivo**
```bash
# Listar dispositivos disponibles
flutter devices

# Ejecutar en emulador Android
flutter run -d emulator-5554

# Ejecutar en navegador web
flutter run -d chrome

# Ejecutar en dispositivo físico
flutter run
```

### **Dependencias Principales**

#### **Core Dependencies**
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  provider: ^6.1.2           # Gestión de estado
  http: ^1.2.2               # Cliente HTTP
  shared_preferences: ^2.3.2 # Almacenamiento local
  intl: ^0.19.0              # Internacionalización
```

#### **Development Dependencies**
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0      # Análisis de código
  build_runner: ^2.4.13      # Generación de código
```

## 🧪 Testing y Desarrollo

### **Quick Login para Testing**

La aplicación incluye una pantalla de Quick Login que permite acceso rápido con credenciales predefinidas:

#### **Acceso a Quick Login**
1. Abrir la aplicación
2. En la pantalla de login, tocar el botón **"⚡ Quick Login - Usuarios de Prueba"**
3. Seleccionar el usuario deseado
4. La aplicación iniciará sesión automáticamente

#### **Usuario Recomendado para Pruebas de Pagos**
- **Usuario**: `residente1`
- **Contraseña**: `isaelOrtiz2`
- **Perfil**: Residente con gastos comunes y multas pendientes

### **Flujo de Pruebas Recomendado**

#### **1. Autenticación**
```
1. Usar Quick Login con residente1
2. Verificar redirección a pantalla principal
3. Confirmar datos de perfil cargados
```

#### **2. Gestión de Pagos**
```
1. Navegar a "Mis Pagos"
2. Verificar carga de gastos comunes y multas
3. Realizar pago individual de un concepto
4. Probar pago múltiple con selección
5. Verificar actualización de estados
```

#### **3. Funcionalidades Adicionales**
```
1. Revisar avisos del condominio
2. Gestionar información de perfil
3. Probar navegación entre pantallas
4. Verificar manejo de errores
```

## 🐛 Solución de Problemas

### **Errores Comunes y Soluciones**

#### **Error 401 - Unauthorized**
```
Problema: Error de autenticación
Solución: 
1. Usar Quick Login con credenciales válidas
2. Verificar conectividad con el backend
3. Revisar configuración de endpoints
```

#### **Error 404 - Not Found**
```
Problema: Endpoint no encontrado
Solución:
1. Verificar URL base del API (10.0.2.2:8000 para emulador)
2. Confirmar que el backend esté ejecutándose
3. Revisar endpoints en services/endpoints.dart
```

#### **Problemas de Compilación**
```bash
# Limpiar cache de Flutter
flutter clean

# Reinstalar dependencias
flutter pub get

# Verificar configuración
flutter doctor
```

#### **Hot Reload No Funciona**
```bash
# Hacer Hot Restart completo
R (en terminal de Flutter)

# O reiniciar completamente
flutter run -d <device-id>
```

## 📱 Plataformas Soportadas

### **Android**
- **SDK Mínimo**: Android 21 (5.0 Lollipop)
- **SDK Objetivo**: Android 34
- **Arquitecturas**: ARM64, x86_64
- **Configuración**: `android/app/build.gradle.kts`

### **iOS**
- **Versión Mínima**: iOS 12.0
- **Arquitecturas**: ARM64
- **Configuración**: `ios/Runner/Info.plist`

### **Web**
- **Navegadores**: Chrome, Firefox, Safari, Edge
- **Configuración**: `web/index.html`

### **Desktop**
- **Windows**: Windows 10+
- **macOS**: macOS 10.15+
- **Linux**: Ubuntu 20.04+

## 🔮 Futuras Mejoras

### **Funcionalidades Planificadas**
- [ ] Sistema de notificaciones push
- [ ] Chat integrado entre residentes
- [ ] Calendario de eventos del condominio
- [ ] Reportes financieros avanzados
- [ ] Integración con sistemas de domótica
- [ ] App móvil para personal de mantenimiento

### **Mejoras Técnicas**
- [ ] Migración a arquitectura clean
- [ ] Implementación de testing automatizado
- [ ] Optimización de rendimiento
- [ ] Soporte offline parcial
- [ ] Sincronización en tiempo real

## 👥 Contribución

### **Cómo Contribuir**
1. Fork del repositorio
2. Crear rama de feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit de cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crear Pull Request

### **Estándares de Código**
- Seguir convenciones de Dart/Flutter
- Documentar funciones públicas
- Escribir tests para nueva funcionalidad
- Usar linter configurado (`flutter_lints`)

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 📞 Contacto y Soporte

- **Desarrollador**: Herlandt
- **Repository**: [https://github.com/herlandt/smart_login](https://github.com/herlandt/smart_login)
- **Issues**: [GitHub Issues](https://github.com/herlandt/smart_login/issues)

---

## 📝 Changelog

### **Versión 2.0.0 - Actualización Completa del Sistema de Pagos**

#### **🎉 Nuevas Funcionalidades**
- ✅ **Sistema de Pagos Completamente Reescrito**
  - Endpoints corregidos de `/pagar/` a `/registrar_pago/`
  - Transmisión completa de datos de pago
  - Soporte para pagos individuales y por lotes
  - Validaciones mejoradas de montos y métodos

- ✅ **Quick Login System**
  - 7 usuarios de prueba predefinidos
  - Acceso rápido para testing
  - Diferenciación de roles automática

- ✅ **UI/UX Mejorada**
  - Selección múltiple con checkboxes
  - Indicadores de estado visual
  - Navegación fluida entre pantallas
  - Diseño responsive y moderno

#### **🔧 Correcciones Técnicas**
- 🐛 **Endpoints API Corregidos**
  - `pagarGasto()`: `/gastos/{id}/registrar_pago/`
  - `pagarMulta()`: `/multas/{id}/registrar_pago/`
  - Eliminación de endpoints incorrectos `/pagar/`

- 🐛 **Autenticación Mejorada**
  - Manejo correcto de tokens JWT
  - Gestión de errores 401/403
  - Quick Login para bypass en desarrollo

- 🐛 **Gestión de Estado**
  - Provider pattern correctamente implementado
  - Sincronización de datos mejorada
  - Manejo de errores robusto

#### **📱 Funcionalidades Reemplazadas**
- ❌ **Eliminado**: Mensajes "🚧 Funcionalidad en desarrollo"
- ✅ **Implementado**: Navegación real a pantallas funcionales
- ❌ **Eliminado**: Callbacks vacíos en menú principal
- ✅ **Implementado**: Navegación completa con MaterialPageRoute

#### **🧪 Testing y Validación**
- ✅ Compilación exitosa en Android/iOS/Web
- ✅ Navegación completa entre pantallas
- ✅ Pagos individuales funcionales
- ✅ Pagos múltiples operativos
- ✅ Quick Login completamente operativo
- ✅ Manejo de errores robusto

---

**🚀 La aplicación Smart Login ahora es completamente funcional con un sistema de pagos robusto, autenticación mejorada y una experiencia de usuario optimizada.**