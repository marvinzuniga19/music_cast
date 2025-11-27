import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song_model.dart';

/// Represents a single playback record
class PlaybackRecord {
  final Song song;
  final DateTime timestamp;
  final Duration? playDuration;

  PlaybackRecord({
    required this.song,
    required this.timestamp,
    this.playDuration,
  });

  factory PlaybackRecord.fromJson(Map<String, dynamic> json) {
    return PlaybackRecord(
      song: Song.fromJson(json['song'] as Map<String, dynamic>),
      timestamp: DateTime.parse(json['timestamp'] as String),
      playDuration: json['playDuration'] != null
          ? Duration(seconds: json['playDuration'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'song': song.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'playDuration': playDuration?.inSeconds,
    };
  }
}

/// Tracks and manages playback history
class PlaybackHistory extends ChangeNotifier {
  final List<PlaybackRecord> _history = [];
  static const String _storageKey = 'playback_history';
  static const int _maxHistorySize = 500; // Limit history size

  List<PlaybackRecord> get history => List.unmodifiable(_history);

  /// Load history from storage
  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyString = prefs.getString(_storageKey);

      if (historyString != null && historyString.isNotEmpty) {
        final List<dynamic> historyJson = jsonDecode(historyString);
        _history.clear();
        _history.addAll(
          historyJson.map((json) => PlaybackRecord.fromJson(json)).toList(),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
    }
  }

  /// Save history to storage
  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _history.map((r) => r.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(historyJson));
    } catch (e) {
      debugPrint('Error saving history: $e');
    }
  }

  /// Add a playback record
  Future<void> addRecord(Song song, {Duration? playDuration}) async {
    final record = PlaybackRecord(
      song: song,
      timestamp: DateTime.now(),
      playDuration: playDuration,
    );

    _history.insert(0, record); // Add to beginning

    // Limit history size
    if (_history.length > _maxHistorySize) {
      _history.removeRange(_maxHistorySize, _history.length);
    }

    await _saveHistory();
    notifyListeners();
  }

  /// Get recently played songs (unique)
  List<Song> getRecentlyPlayed({int limit = 20}) {
    final seen = <String>{};
    final recent = <Song>[];

    for (var record in _history) {
      if (!seen.contains(record.song.id)) {
        seen.add(record.song.id);
        recent.add(record.song);
        if (recent.length >= limit) break;
      }
    }

    return recent;
  }

  /// Get most played songs
  List<MapEntry<Song, int>> getMostPlayed({int limit = 20}) {
    final songCounts = <String, MapEntry<Song, int>>{};

    for (var record in _history) {
      final existing = songCounts[record.song.id];
      if (existing != null) {
        songCounts[record.song.id] = MapEntry(record.song, existing.value + 1);
      } else {
        songCounts[record.song.id] = MapEntry(record.song, 1);
      }
    }

    final sorted = songCounts.values.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(limit).toList();
  }

  /// Get play count for a specific song
  int getPlayCount(String songId) {
    return _history.where((r) => r.song.id == songId).length;
  }

  /// Get total listening time
  Duration getTotalListeningTime() {
    var total = Duration.zero;
    for (var record in _history) {
      if (record.playDuration != null) {
        total += record.playDuration!;
      }
    }
    return total;
  }

  /// Get listening stats for a time period
  Map<String, dynamic> getStats({DateTime? since}) {
    final relevantHistory = since != null
        ? _history.where((r) => r.timestamp.isAfter(since)).toList()
        : _history;

    final uniqueSongs = <String>{};
    var totalDuration = Duration.zero;

    for (var record in relevantHistory) {
      uniqueSongs.add(record.song.id);
      if (record.playDuration != null) {
        totalDuration += record.playDuration!;
      }
    }

    return {
      'totalPlays': relevantHistory.length,
      'uniqueSongs': uniqueSongs.length,
      'totalDuration': totalDuration,
    };
  }

  /// Clear all history
  Future<void> clearHistory() async {
    _history.clear();
    await _saveHistory();
    notifyListeners();
  }

  /// Clear history older than a certain date
  Future<void> clearOldHistory(DateTime before) async {
    _history.removeWhere((r) => r.timestamp.isBefore(before));
    await _saveHistory();
    notifyListeners();
  }
}
