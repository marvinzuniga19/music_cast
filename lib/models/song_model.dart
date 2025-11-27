class Song {
  final String id;
  final String title;
  final String artist;
  final String albumArt;
  final String url;
  final Duration? duration;
  final String? album;
  final int? year;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.albumArt,
    required this.url,
    this.duration,
    this.album,
    this.year,
  });

  /// Creates a Song from JSON data
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      albumArt: json['albumArt'] as String,
      url: json['url'] as String,
      duration: json['duration'] != null
          ? Duration(seconds: json['duration'] as int)
          : null,
      album: json['album'] as String?,
      year: json['year'] as int?,
    );
  }

  /// Converts Song to JSON data
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'albumArt': albumArt,
      'url': url,
      'duration': duration?.inSeconds,
      'album': album,
      'year': year,
    };
  }

  /// Creates a copy of this Song with the given fields replaced
  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? albumArt,
    String? url,
    Duration? duration,
    String? album,
    int? year,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      albumArt: albumArt ?? this.albumArt,
      url: url ?? this.url,
      duration: duration ?? this.duration,
      album: album ?? this.album,
      year: year ?? this.year,
    );
  }

  /// Validates if the song URL is valid
  bool get hasValidUrl {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute || url.startsWith('/');
    } catch (e) {
      return false;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Song(id: $id, title: $title, artist: $artist)';
}
