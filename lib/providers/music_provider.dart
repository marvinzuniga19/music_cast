import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song_model.dart';
import '../services/audio_handler.dart';

class MusicProvider extends ChangeNotifier {
  final AudioHandler _audioHandler;

  // Estado de reproducción
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  Song? _currentSong;

  // Estado de UI
  Color? _dominantColor;

  // Estado de Chromecast
  bool _isCasting = false;
  String? _connectedDeviceName;

  // Lista de reproducción simulada
  final List<Song> _playlist = [
    Song(
      id: '1',
      title: 'Jazz Vibes',
      artist: 'Smooth Trio',
      albumArt:
          'https://images.unsplash.com/photo-1511192336575-5a79af67a629?auto=format&fit=crop&w=500&q=80',
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    ),
    Song(
      id: '2',
      title: 'Night Drive',
      artist: 'Synthwave Boy',
      albumArt:
          'https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?auto=format&fit=crop&w=500&q=80',
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    ),
    Song(
      id: '3',
      title: 'Acoustic Morning',
      artist: 'The Strings',
      albumArt:
          'https://images.unsplash.com/photo-1485579149621-3123dd979885?auto=format&fit=crop&w=500&q=80',
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
    ),
  ];

  MusicProvider(this._audioHandler) {
    _initAudioListeners();
    _loadLastSong();
  }

  void _initAudioListeners() {
    _audioHandler.playbackState.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    _audioHandler.mediaItem.listen((item) {
      if (item != null) {
        _duration = item.duration ?? Duration.zero;
        notifyListeners();
      }
    });

    // Escuchar posición real del player (cast a AudioPlayerHandler para acceso directo si es necesario,
    // o usar un stream custom si AudioService no expone posición continua eficientemente)
    if (_audioHandler is AudioPlayerHandler) {
      _audioHandler.player.onPositionChanged.listen((pos) {
        _position = pos;
        notifyListeners();
      });
    }
  }

  // Getters
  bool get isPlaying => _isPlaying;
  bool get isCasting => _isCasting;
  String? get connectedDeviceName => _connectedDeviceName;
  Duration get duration => _duration;
  Duration get position => _position;
  Song? get currentSong => _currentSong;
  List<Song> get playlist => _playlist;
  Color? get dominantColor => _dominantColor;

  // Métodos de Persistencia
  Future<void> _saveLastSong(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_song_id', songId);
  }

  Future<void> _loadLastSong() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSongId = prefs.getString('last_song_id');

    if (lastSongId != null) {
      try {
        final song = _playlist.firstWhere((s) => s.id == lastSongId);
        _currentSong = song;
        _updatePalette(song.albumArt);
        // No reproducimos automáticamente, solo cargamos el estado
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading last song: $e');
      }
    }
  }

  // Métodos de Audio
  Future<void> playSong(Song song) async {
    if (_currentSong?.id != song.id) {
      _currentSong = song;
      _saveLastSong(song.id); // Guardar persistencia
      _updatePalette(song.albumArt);

      final mediaItem = MediaItem(
        id: song.id,
        album: "Music Cast Album",
        title: song.title,
        artist: song.artist,
        artUri: Uri.parse(song.albumArt),
      );

      if (_audioHandler is AudioPlayerHandler) {
        await _audioHandler.playUrl(song.url, mediaItem);
      }
    } else {
      resume();
    }
    notifyListeners();
  }

  Future<void> _updatePalette(String imageUrl) async {
    _dominantColor = null; // Reset temporal
    notifyListeners();

    try {
      final PaletteGenerator generator =
          await PaletteGenerator.fromImageProvider(
            NetworkImage(imageUrl),
            size: const Size(200, 200), // Optimización: usar imagen más pequeña
          );
      _dominantColor =
          generator.dominantColor?.color ?? generator.mutedColor?.color;
      notifyListeners();
    } catch (e) {
      debugPrint('Error generating palette: $e');
    }
  }

  Future<void> pickAndPlaySong() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      if (file.path != null) {
        final newSong = Song(
          id: DateTime.now().toString(), // ID temporal único
          title: file.name,
          artist: 'Local File',
          albumArt:
              'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=500&q=80', // Placeholder
          url: file.path!,
        );

        _playlist.add(newSong);
        await playSong(newSong);
        notifyListeners();
      }
    }
  }

  Future<void> pause() async {
    await _audioHandler.pause();
  }

  Future<void> resume() async {
    await _audioHandler.play();
  }

  Future<void> seek(Duration position) async {
    await _audioHandler.seek(position);
  }

  void next() {
    if (_currentSong == null) return;
    int currentIndex = _playlist.indexOf(_currentSong!);
    if (currentIndex < _playlist.length - 1) {
      playSong(_playlist[currentIndex + 1]);
    }
  }

  void previous() {
    if (_currentSong == null) return;
    int currentIndex = _playlist.indexOf(_currentSong!);
    if (currentIndex > 0) {
      playSong(_playlist[currentIndex - 1]);
    }
  }

  // Métodos de Chromecast
  Future<void> connectToDevice(String deviceName) async {
    await Future.delayed(const Duration(seconds: 1));
    _isCasting = true;
    _connectedDeviceName = deviceName;
    notifyListeners();
  }

  void disconnectCast() {
    _isCasting = false;
    _connectedDeviceName = null;
    notifyListeners();
  }
}
