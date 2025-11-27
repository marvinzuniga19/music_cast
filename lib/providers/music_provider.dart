import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song_model.dart';
import '../services/audio_handler.dart';
import '../services/queue_manager.dart';

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

  // Estado de errores
  String? _errorMessage;

  // Queue Manager
  final QueueManager _queueManager = QueueManager();

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
      _position = state.updatePosition;
      notifyListeners();
    });

    _audioHandler.mediaItem.listen((item) {
      if (item != null) {
        _duration = item.duration ?? Duration.zero;
        notifyListeners();
      }
    });

    // Listen for song completion to auto-play next song
    final handler = _audioHandler;
    if (handler is AudioPlayerHandler) {
      handler.onSongCompleted.listen((_) {
        _handleSongCompletion();
      });
    }
  }

  /// Handles automatic playback when a song completes
  void _handleSongCompletion() {
    debugPrint('Song completed, checking for next song...');

    // Get next song from queue manager based on repeat/shuffle settings
    final nextSong = _queueManager.getNext();

    if (nextSong != null) {
      debugPrint('Auto-playing next song: ${nextSong.title}');
      playSong(nextSong);
    } else {
      debugPrint('No next song available (end of queue, repeat off)');
      // Optionally reset to beginning or show completion message
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
  String? get errorMessage => _errorMessage;
  RepeatMode get repeatMode => _queueManager.repeatMode;
  ShuffleMode get shuffleMode => _queueManager.shuffleMode;

  // Métodos de Persistencia
  Future<void> _saveLastSong(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_song_id', songId);
  }

  Future<void> _savePlaylist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playlistJson = _playlist.map((song) => song.toJson()).toList();
      await prefs.setString('playlist', jsonEncode(playlistJson));
    } catch (e) {
      debugPrint('Error saving playlist: $e');
    }
  }

  Future<void> _loadLastSong() async {
    // Primero cargar la playlist guardada
    await _loadPlaylist();

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

  Future<void> _loadPlaylist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playlistString = prefs.getString('playlist');

      if (playlistString != null && playlistString.isNotEmpty) {
        final List<dynamic> playlistJson = jsonDecode(playlistString);
        _playlist.clear();
        _playlist.addAll(
          playlistJson.map((json) => Song.fromJson(json)).toList(),
        );
      }

      // Inicializar queue manager con la playlist
      if (_playlist.isNotEmpty) {
        _queueManager.setQueue(_playlist);
      }
    } catch (e) {
      debugPrint('Error loading playlist: $e');
      // Si hay error, mantener la playlist por defecto
      if (_playlist.isNotEmpty) {
        _queueManager.setQueue(_playlist);
      }
    }
  }

  // Métodos de Audio
  Future<void> playSong(Song song) async {
    try {
      // Validar URL
      if (!song.hasValidUrl) {
        _showError('URL de canción inválida: ${song.title}');
        return;
      }

      if (_currentSong?.id != song.id) {
        _currentSong = song;
        await _saveLastSong(song.id); // Guardar persistencia
        _updatePalette(song.albumArt);

        // Sync with queue manager so it knows the current song
        _queueManager.jumpToSong(song.id);

        final mediaItem = MediaItem(
          id: song.id,
          album: song.album ?? "Music Cast Album",
          title: song.title,
          artist: song.artist,
          artUri: Uri.parse(song.albumArt),
          duration: song.duration,
        );

        if (_audioHandler is AudioPlayerHandler) {
          await _audioHandler.playUrl(song.url, mediaItem);
        }
      } else {
        await resume();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error playing song: $e');
      _showError('No se pudo reproducir: ${song.title}');
    }
  }

  void _showError(String message) {
    _errorMessage = message;
    notifyListeners();
    // Limpiar error después de 5 segundos
    Future.delayed(const Duration(seconds: 5), () {
      _errorMessage = null;
      notifyListeners();
    });
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
    try {
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
          await _savePlaylist(); // Guardar playlist actualizada
          await playSong(newSong);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      _showError('No se pudo abrir el archivo');
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
    final nextSong = _queueManager.getNext();
    if (nextSong != null) {
      playSong(nextSong);
    }
  }

  void previous() {
    final previousSong = _queueManager.getPrevious();
    if (previousSong != null) {
      playSong(previousSong);
    }
  }

  // Métodos de Queue Management
  void toggleShuffle() {
    _queueManager.toggleShuffle();
    notifyListeners();
  }

  void toggleRepeat() {
    _queueManager.toggleRepeat();
    notifyListeners();
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
