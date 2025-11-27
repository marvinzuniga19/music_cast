import '../models/song_model.dart';

/// Enum for repeat modes
enum RepeatMode {
  off, // No repeat
  one, // Repeat current song
  all, // Repeat entire queue
}

/// Enum for shuffle modes
enum ShuffleMode {
  off, // Play in order
  on, // Play shuffled
}

/// Manages the playback queue with shuffle and repeat functionality
class QueueManager {
  List<Song> _originalQueue = [];
  List<Song> _currentQueue = [];
  int _currentIndex = 0;
  RepeatMode _repeatMode = RepeatMode.off;
  ShuffleMode _shuffleMode = ShuffleMode.off;

  // Getters
  List<Song> get queue => List.unmodifiable(_currentQueue);
  int get currentIndex => _currentIndex;
  RepeatMode get repeatMode => _repeatMode;
  ShuffleMode get shuffleMode => _shuffleMode;
  Song? get currentSong =>
      _currentQueue.isNotEmpty && _currentIndex < _currentQueue.length
      ? _currentQueue[_currentIndex]
      : null;

  /// Initialize the queue with a list of songs
  void setQueue(List<Song> songs, {int startIndex = 0}) {
    _originalQueue = List.from(songs);
    _currentQueue = List.from(songs);
    _currentIndex = startIndex.clamp(0, songs.length - 1);

    if (_shuffleMode == ShuffleMode.on) {
      _shuffleQueue();
    }
  }

  /// Add a song to the end of the queue
  void addToQueue(Song song) {
    _originalQueue.add(song);
    _currentQueue.add(song);
  }

  /// Add a song to play next (after current song)
  void playNext(Song song) {
    final nextIndex = _currentIndex + 1;
    _originalQueue.insert(nextIndex, song);
    _currentQueue.insert(nextIndex, song);
  }

  /// Remove a song from the queue
  void removeSong(String songId) {
    final currentSong = this.currentSong;
    _originalQueue.removeWhere((s) => s.id == songId);
    _currentQueue.removeWhere((s) => s.id == songId);

    // Adjust current index if needed
    if (currentSong != null) {
      _currentIndex = _currentQueue.indexWhere((s) => s.id == currentSong.id);
      if (_currentIndex == -1) _currentIndex = 0;
    }
  }

  /// Get the next song based on repeat and shuffle modes
  Song? getNext() {
    if (_currentQueue.isEmpty) return null;

    // If repeat one, return current song
    if (_repeatMode == RepeatMode.one) {
      return currentSong;
    }

    // Move to next song
    if (_currentIndex < _currentQueue.length - 1) {
      _currentIndex++;
      return _currentQueue[_currentIndex];
    }

    // At end of queue
    if (_repeatMode == RepeatMode.all) {
      _currentIndex = 0;
      return _currentQueue[_currentIndex];
    }

    // No repeat, at end
    return null;
  }

  /// Get the previous song
  Song? getPrevious() {
    if (_currentQueue.isEmpty) return null;

    if (_currentIndex > 0) {
      _currentIndex--;
      return _currentQueue[_currentIndex];
    }

    // At beginning of queue
    if (_repeatMode == RepeatMode.all) {
      _currentIndex = _currentQueue.length - 1;
      return _currentQueue[_currentIndex];
    }

    return null;
  }

  /// Jump to a specific song in the queue
  bool jumpToSong(String songId) {
    final index = _currentQueue.indexWhere((s) => s.id == songId);
    if (index != -1) {
      _currentIndex = index;
      return true;
    }
    return false;
  }

  /// Toggle shuffle mode
  void toggleShuffle() {
    _shuffleMode = _shuffleMode == ShuffleMode.off
        ? ShuffleMode.on
        : ShuffleMode.off;

    if (_shuffleMode == ShuffleMode.on) {
      _shuffleQueue();
    } else {
      _unshuffleQueue();
    }
  }

  /// Toggle repeat mode (cycles through off -> all -> one -> off)
  void toggleRepeat() {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.off;
        break;
    }
  }

  /// Shuffle the queue while keeping current song at current position
  void _shuffleQueue() {
    if (_currentQueue.isEmpty) return;

    final currentSong = this.currentSong;
    _currentQueue.shuffle();

    // Move current song to current index
    if (currentSong != null) {
      final newIndex = _currentQueue.indexWhere((s) => s.id == currentSong.id);
      if (newIndex != -1 && newIndex != _currentIndex) {
        final song = _currentQueue.removeAt(newIndex);
        _currentQueue.insert(_currentIndex, song);
      }
    }
  }

  /// Restore original queue order
  void _unshuffleQueue() {
    final currentSong = this.currentSong;
    _currentQueue = List.from(_originalQueue);

    // Find current song in unshuffled queue
    if (currentSong != null) {
      _currentIndex = _currentQueue.indexWhere((s) => s.id == currentSong.id);
      if (_currentIndex == -1) _currentIndex = 0;
    }
  }

  /// Clear the queue
  void clear() {
    _originalQueue.clear();
    _currentQueue.clear();
    _currentIndex = 0;
  }
}
