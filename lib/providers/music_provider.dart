import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/song_model.dart';

class MusicProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Estado de reproducción
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  Song? _currentSong;

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

  MusicProvider() {
    _initAudioListeners();
  }

  void _initAudioListeners() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      _duration = newDuration;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      _position = newPosition;
      notifyListeners();
    });
  }

  // Getters
  bool get isPlaying => _isPlaying;
  bool get isCasting => _isCasting;
  String? get connectedDeviceName => _connectedDeviceName;
  Duration get duration => _duration;
  Duration get position => _position;
  Song? get currentSong => _currentSong;
  List<Song> get playlist => _playlist;

  // Métodos de Audio
  Future<void> playSong(Song song) async {
    if (_currentSong?.id != song.id) {
      _currentSong = song;
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(song.url));
    } else {
      resume();
    }
    notifyListeners();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> resume() async {
    await _audioPlayer.resume();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
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
