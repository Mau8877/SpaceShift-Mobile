# 🏡 SpaceShift Mobile

Aplicación móvil del sistema inmobiliario **SpaceShift**, desarrollada en Flutter. Permite a los usuarios explorar propiedades, ver detalles y autenticarse mediante el backend de Spring Boot.

---

## 📋 Requisitos previos

| Herramienta | Versión mínima |
|---|---|
| Flutter SDK | `^3.11.1` |
| Dart SDK | `^3.11.1` |
| Android Studio / Xcode | Última versión estable |
| Java (para Android) | 17+ |

---

## 🚀 Instalación

```bash
# 1. Clona el repositorio
git clone <url-del-repo>
cd space_shift

# 2. Instala las dependencias
flutter pub get

# 3. Genera los archivos de Riverpod (ver sección abajo)
dart run build_runner build --delete-conflicting-outputs

# 4. Configura las variables de entorno (ver sección .env)

# 5. Corre la app
flutter run
```

---

## 🔑 Configuración del entorno (.env)

En la raíz del proyecto encontrarás un archivo `.env.example`. Cópialo y renómbralo a `.env`:

```bash
cp .env.example .env
```

Luego edita `.env` con la URL de tu instancia del backend:

```env
# URL base del backend Spring Boot (sin barra final)
API_BASE_URL=http://192.168.1.100:8080

# Ejemplo producción:
# API_BASE_URL=https://api.spaceshift.com
```

> ⚠️ **Importante:** El archivo `.env` está en `.gitignore`. Nunca lo subas al repositorio. Cada desarrollador debe tener el suyo.
>
> 💡 **Tip para Android Emulator:** usa `http://10.0.2.2:8080` en lugar de `localhost` para apuntar a tu máquina local.

---

## 🏗️ Arquitectura del proyecto

El proyecto sigue **Clean Architecture** dividida en features. Cada feature es completamente independiente.

```
lib/
├── core/                          # Infraestructura compartida
│   ├── network/
│   │   ├── dio_provider.dart      # Cliente HTTP (Dio) configurado con baseUrl del .env
│   │   └── token_storage.dart     # Manejo seguro del JWT (flutter_secure_storage)
│   ├── routing/
│   │   └── app_router.dart        # Rutas de la app (GoRouter)
│   └── theme/
│       └── app_theme.dart         # Paleta de colores light/dark (shadcn_ui)
│
└── features/
    ├── auth/                      # 🔐 Autenticación
    │   ├── data/
    │   │   └── auth_repository.dart       # POST /auth/login → guarda JWT
    │   ├── domain/
    │   │   └── user_model.dart            # Modelo del usuario autenticado
    │   └── presentation/
    │       ├── providers/
    │       │   └── auth_controller.dart   # Estado del login (AsyncNotifier)
    │       ├── screens/
    │       │   └── login_screen.dart      # Pantalla de login
    │       └── widgets/
    │           └── login_form.dart        # Formulario separado (opcional)
    │
    └── properties/                # 🏡 Catálogo de inmuebles
        ├── data/
        │   └── properties_repository.dart  # GET /properties → lista de inmuebles
        ├── domain/
        │   └── property_model.dart         # Modelo: id, titulo, precio, fotos...
        └── presentation/
            ├── providers/
            │   ├── properties_provider.dart       # Lista de propiedades en memoria
            │   └── property_filter_provider.dart  # Filtros de búsqueda (opcional)
            ├── screens/
            │   ├── property_list_screen.dart      # Pantalla principal / Home
            │   └── property_detail_screen.dart    # Detalle al tocar una propiedad
            └── widgets/
                ├── property_card.dart             # Tarjeta de propiedad (shadcn_ui)
                └── property_image_carousel.dart   # Carrusel de fotos
```

### Flujo de una feature completa

```
UI (screen/widget)
    └── lee/escucha → Provider (Riverpod)
                          └── llama → Repository (data layer)
                                          └── usa → Dio (HTTP) / TokenStorage
```

---

## ⚡ Riverpod — Guía de uso

Este proyecto usa **Riverpod con generación de código** (`riverpod_annotation` + `riverpod_generator`).

### Archivos autogenerados

Cada archivo que tenga la anotación `@riverpod` necesita su correspondiente `.g.dart`. Estos archivos **no se editan manualmente** y no se suben al repositorio (están en `.gitignore`).

Para generarlos o actualizarlos:

```bash
# Genera una sola vez
dart run build_runner build --delete-conflicting-outputs

# Modo watch (se regenera automáticamente al guardar)
dart run build_runner watch --delete-conflicting-outputs
```

> 🔴 Si ves el error `part 'xxx.g.dart'` en rojo, es porque falta correr el comando anterior.

---

### Tipos de providers usados

#### 1. Provider simple (datos de solo lectura)

Úsalo para exponer una instancia de un repositorio o servicio.

```dart
// auth_repository.dart
part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    ref.watch(dioProvider),
    ref.watch(tokenStorageProvider),
  );
}
```

```dart
// En un widget o en otro provider:
final repo = ref.watch(authRepositoryProvider);
```

---

#### 2. AsyncNotifier (operaciones asíncronas con estado)

Úsalo para lógica de negocio que maneja estados de carga, error y éxito. Es el patrón principal para formularios y llamadas a la API.

```dart
// auth_controller.dart
part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}  // Estado inicial: sin datos

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();  // ← Muestra un loader
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).login(email, password);
    });
    // Si lanza excepción, state = AsyncError automáticamente
  }
}
```

```dart
// En el widget que llama al login:
final authState = ref.watch(authControllerProvider);

// Reaccionar al estado:
authState.when(
  data: (_) => context.go('/home'),       // ✅ Éxito
  loading: () => CircularProgressIndicator(),  // ⏳ Cargando
  error: (e, _) => Text('Error: $e'),     // ❌ Error
);

// Llamar al método:
ref.read(authControllerProvider.notifier).login(email, password);
```

---

#### 3. FutureProvider (carga de datos simple)

Úsalo para cargar una lista de datos de la API sin lógica extra.

```dart
// properties_provider.dart
part 'properties_provider.g.dart';

@riverpod
Future<List<PropertyModel>> properties(Ref ref) async {
  return ref.watch(propertiesRepositoryProvider).getProperties();
}
```

```dart
// En la pantalla de lista:
final propertiesAsync = ref.watch(propertiesProvider);

propertiesAsync.when(
  data: (list) => ListView.builder(
    itemCount: list.length,
    itemBuilder: (_, i) => PropertyCard(property: list[i]),
  ),
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (e, _) => Center(child: Text('Error al cargar propiedades')),
);
```

---

#### 4. StateProvider (estado UI simple)

Úsalo para valores sencillos como un campo de búsqueda o un filtro.

```dart
// property_filter_provider.dart
part 'property_filter_provider.g.dart';

@riverpod
class PropertyFilter extends _$PropertyFilter {
  @override
  String build() => '';  // Filtro vacío por defecto

  void update(String query) => state = query;
}
```

```dart
// Leer y escribir el filtro:
final filter = ref.watch(propertyFilterProvider);
ref.read(propertyFilterProvider.notifier).update('Miraflores');
```

---

### Regla de oro: `watch` vs `read`

| | `ref.watch` | `ref.read` |
|---|---|---|
| **Cuándo** | Dentro del `build()` de un widget o provider | Dentro de callbacks (onPressed, métodos) |
| **Efecto** | Reconstruye el widget cuando cambia | Lee el valor una sola vez, sin suscribirse |
| **Ejemplo** | `ref.watch(propertiesProvider)` | `ref.read(authControllerProvider.notifier).login(...)` |

---

## 🎨 Tema y estilos

La app usa **shadcn_ui** con una paleta de colores sincronizada con el sitio web. El tema cambia automáticamente entre light y dark según el sistema operativo.

```dart
// Acceder a los colores del tema activo en cualquier widget:
final colors = ShadTheme.of(context).colorScheme;

Text('Hola', style: TextStyle(color: colors.primary));
Container(color: colors.card);
```

Para colores estáticos (sin depender del tema), usa la clase `AppColors`:

```dart
import 'core/theme/app_theme.dart';

// Light
AppColors.lPrimary      // Azul principal
AppColors.lDestructive  // Rojo de error

// Dark
AppColors.dBackground   // Fondo oscuro
```

---

## 📦 Dependencias principales

| Paquete | Uso |
|---|---|
| `shadcn_ui ^0.53.3` | Componentes UI (botones, cards, inputs, etc.) |
| `go_router ^17.1.0` | Navegación declarativa |
| `flutter_riverpod ^3.3.1` | Gestión de estado |
| `riverpod_annotation ^4.0.2` | Anotaciones para generación de código |
| `dio ^5.9.2` | Cliente HTTP |
| `flutter_secure_storage ^10.0.0` | Almacenamiento seguro del JWT |
| `flutter_dotenv ^6.0.0` | Variables de entorno desde `.env` |

---

## 🤝 Convenciones del equipo

- **Nombrar providers** en `camelCase` terminando en `Provider`: `authRepositoryProvider`, `propertiesProvider`.
- **Un feature = una carpeta** bajo `features/`. No mezcles lógica de features distintas.
- **Los `.g.dart` no se tocan ni se suben** al repositorio.
- **Los modelos** van en `domain/` y son clases puras de Dart (sin imports de Flutter ni Dio).
- **Los repositorios** van en `data/` y son los únicos que hablan con Dio.
- **Las pantallas** van en `presentation/screens/` y los componentes reutilizables en `presentation/widgets/`.