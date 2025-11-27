# Music Flutter Cast 🎵

Una aplicación de música moderna y elegante construida con Flutter, con soporte para reproducción local, streaming, y casting a dispositivos Chromecast.

## ✨ Características

### Reproducción de Música
- ✅ Reproducción de música local y streaming
- ✅ Soporte para archivos de audio locales
- ✅ Reproducción en segundo plano con notificaciones
- ✅ Control de reproducción completo (play, pause, next, previous, seek)
- ✅ Avance/retroceso rápido de 10 segundos

### Gestión de Playlist
- ✅ Cola de reproducción inteligente
- ✅ Modo aleatorio (shuffle)
- ✅ Modos de repetición (off, all, one)
- ✅ Persistencia de playlist y última canción reproducida
- ✅ Playlists personalizadas (crear, editar, eliminar)

### Interfaz de Usuario
- ✅ Diseño moderno con tema oscuro
- ✅ Colores dinámicos basados en carátula del álbum
- ✅ Animaciones suaves y transiciones Hero
- ✅ Mini reproductor persistente
- ✅ Gestos de deslizamiento para cambiar canciones
- ✅ Búsqueda de canciones por título o artista

### Características Avanzadas
- ✅ Soporte para Chromecast (simulado)
- ✅ Historial de reproducción
- ✅ Estadísticas de escucha
- ✅ Manejo robusto de errores con feedback visual
- ✅ Caché de imágenes optimizado

## 🚀 Instalación

### Requisitos Previos
- Flutter SDK (^3.10.0)
- Dart SDK (^3.10.0)
- Android Studio / Xcode (para desarrollo móvil)

### Pasos de Instalación

1. **Clonar el repositorio**
```bash
git clone <repository-url>
cd music_flutter_cast
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Ejecutar la aplicación**
```bash
flutter run
```

## 🏗️ Arquitectura

La aplicación sigue una arquitectura limpia y modular:

### Patrón de Estado
- **Provider**: Gestión de estado reactiva
- **ChangeNotifier**: Para notificar cambios en el estado

### Servicios
- **AudioService**: Reproducción en segundo plano
- **AudioHandler**: Manejo de audio con audioplayers
- **QueueManager**: Gestión de cola con shuffle/repeat
- **PlaylistManager**: Gestión de playlists personalizadas
- **PlaybackHistory**: Seguimiento de historial de reproducción

### Capas
```
┌─────────────────────────────────────┐
│         UI Layer (Screens)          │
│  - HomeScreen, PlayerScreen, etc.   │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│      State Management (Provider)     │
│         - MusicProvider              │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│         Services Layer               │
│  - AudioHandler, QueueManager, etc.  │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│          Models Layer                │
│  - Song, Playlist, PlaybackRecord    │
└─────────────────────────────────────┘
```

## 📁 Estructura del Proyecto

```
lib/
├── models/              # Modelos de datos
│   └── song_model.dart
├── providers/           # Gestión de estado
│   └── music_provider.dart
├── screens/             # Pantallas principales
│   ├── home_screen.dart
│   └── player_screen.dart
├── services/            # Servicios y lógica de negocio
│   ├── audio_handler.dart
│   ├── queue_manager.dart
│   ├── playlist_manager.dart
│   └── playback_history.dart
├── widgets/             # Widgets reutilizables
│   ├── mini_player.dart
│   ├── cast_device_selector.dart
│   └── song_search_delegate.dart
└── main.dart           # Punto de entrada
```

## 🎨 Características de UI/UX

### Animaciones
- **Hero Animations**: Transición suave de carátulas entre pantallas
- **AnimatedContainer**: Animación del mini reproductor
- **Gradientes Dinámicos**: Colores extraídos de las carátulas

### Gestos
- **Swipe Horizontal**: Cambiar canciones en pantalla de reproducción
- **Tap**: Reproducir canciones, abrir reproductor completo
- **Long Press**: (Futuro) Opciones adicionales

## 🔧 Dependencias Principales

```yaml
dependencies:
  provider: ^6.0.0              # Gestión de estado
  audio_service: ^0.18.18       # Reproducción en segundo plano
  audioplayers: ^5.1.0          # Reproductor de audio
  cached_network_image: ^3.2.3  # Caché de imágenes
  palette_generator: ^0.3.3+7   # Extracción de colores
  shared_preferences: ^2.5.3    # Almacenamiento local
  file_picker: ^8.0.0           # Selector de archivos
  permission_handler: ^11.3.0   # Manejo de permisos
```

## 📊 Roadmap

### Completado ✅
- [x] Reproducción básica de audio
- [x] Mini reproductor
- [x] Pantalla de reproductor completa
- [x] Búsqueda de canciones
- [x] Persistencia de estado
- [x] Shuffle y repeat
- [x] Gestión de cola
- [x] Playlists personalizadas
- [x] Historial de reproducción

### En Progreso 🚧
- [ ] Ecualizador
- [ ] Letras de canciones
- [ ] Integración real con Chromecast
- [ ] Temas personalizables

### Futuro 🔮
- [ ] Modo offline
- [ ] Sincronización en la nube
- [ ] Compartir playlists
- [ ] Recomendaciones inteligentes
- [ ] Visualizador de audio
- [ ] Soporte para podcasts

## 🧪 Testing

Ejecutar tests unitarios:
```bash
flutter test
```

Ejecutar análisis de código:
```bash
flutter analyze
```

## 📝 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

## 👥 Contribuciones

Las contribuciones son bienvenidas. Por favor:
1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📧 Contacto

Para preguntas o sugerencias, por favor abre un issue en GitHub.

---

**Hecho con ❤️ usando Flutter**

