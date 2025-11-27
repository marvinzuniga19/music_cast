import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song_model.dart';

/// Represents a custom playlist
class Playlist {
  final String id;
  final String name;
  final List<Song> songs;
  final String? coverImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Playlist({
    required this.id,
    required this.name,
    required this.songs,
    this.coverImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      songs: (json['songs'] as List<dynamic>)
          .map((s) => Song.fromJson(s as Map<String, dynamic>))
          .toList(),
      coverImage: json['coverImage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'songs': songs.map((s) => s.toJson()).toList(),
      'coverImage': coverImage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Playlist copyWith({
    String? id,
    String? name,
    List<Song>? songs,
    String? coverImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      songs: songs ?? this.songs,
      coverImage: coverImage ?? this.coverImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Manages custom playlists
class PlaylistManager extends ChangeNotifier {
  final List<Playlist> _playlists = [];
  static const String _storageKey = 'custom_playlists';

  List<Playlist> get playlists => List.unmodifiable(_playlists);

  /// Load playlists from storage
  Future<void> loadPlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playlistsString = prefs.getString(_storageKey);

      if (playlistsString != null && playlistsString.isNotEmpty) {
        final List<dynamic> playlistsJson = jsonDecode(playlistsString);
        _playlists.clear();
        _playlists.addAll(
          playlistsJson.map((json) => Playlist.fromJson(json)).toList(),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading playlists: $e');
    }
  }

  /// Save playlists to storage
  Future<void> _savePlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playlistsJson = _playlists.map((p) => p.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(playlistsJson));
    } catch (e) {
      debugPrint('Error saving playlists: $e');
    }
  }

  /// Create a new playlist
  Future<void> createPlaylist(String name, {String? coverImage}) async {
    final playlist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      songs: [],
      coverImage: coverImage,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _playlists.add(playlist);
    await _savePlaylists();
    notifyListeners();
  }

  /// Delete a playlist
  Future<void> deletePlaylist(String playlistId) async {
    _playlists.removeWhere((p) => p.id == playlistId);
    await _savePlaylists();
    notifyListeners();
  }

  /// Rename a playlist
  Future<void> renamePlaylist(String playlistId, String newName) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      _playlists[index] = _playlists[index].copyWith(
        name: newName,
        updatedAt: DateTime.now(),
      );
      await _savePlaylists();
      notifyListeners();
    }
  }

  /// Add a song to a playlist
  Future<void> addSongToPlaylist(String playlistId, Song song) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final playlist = _playlists[index];
      // Avoid duplicates
      if (!playlist.songs.any((s) => s.id == song.id)) {
        final updatedSongs = List<Song>.from(playlist.songs)..add(song);
        _playlists[index] = playlist.copyWith(
          songs: updatedSongs,
          updatedAt: DateTime.now(),
        );
        await _savePlaylists();
        notifyListeners();
      }
    }
  }

  /// Remove a song from a playlist
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final playlist = _playlists[index];
      final updatedSongs = playlist.songs.where((s) => s.id != songId).toList();
      _playlists[index] = playlist.copyWith(
        songs: updatedSongs,
        updatedAt: DateTime.now(),
      );
      await _savePlaylists();
      notifyListeners();
    }
  }

  /// Get a playlist by ID
  Playlist? getPlaylist(String playlistId) {
    try {
      return _playlists.firstWhere((p) => p.id == playlistId);
    } catch (e) {
      return null;
    }
  }

  /// Reorder songs in a playlist
  Future<void> reorderSongs(
    String playlistId,
    int oldIndex,
    int newIndex,
  ) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final playlist = _playlists[index];
      final updatedSongs = List<Song>.from(playlist.songs);

      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      final song = updatedSongs.removeAt(oldIndex);
      updatedSongs.insert(newIndex, song);

      _playlists[index] = playlist.copyWith(
        songs: updatedSongs,
        updatedAt: DateTime.now(),
      );
      await _savePlaylists();
      notifyListeners();
    }
  }
}
