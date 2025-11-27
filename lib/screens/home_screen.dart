import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../widgets/mini_player.dart';

import '../widgets/song_search_delegate.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Cast'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: SongSearchDelegate());
            },
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: () => Provider.of<MusicProvider>(
              context,
              listen: false,
            ).pickAndPlaySong(),
            tooltip: 'Abrir archivo local',
          ),
          IconButton(icon: const Icon(Icons.person), onPressed: () {}),
        ],
      ),
      body: Consumer<MusicProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            itemCount: provider.playlist.length,
            itemBuilder: (context, index) {
              final song = provider.playlist[index];
              final isPlaying = provider.currentSong?.id == song.id;

              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    song.albumArt,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(width: 50, height: 50, color: Colors.grey),
                  ),
                ),
                title: Text(
                  song.title,
                  style: TextStyle(
                    color: isPlaying ? Colors.blueAccent : Colors.white,
                    fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(song.artist),
                trailing: isPlaying
                    ? const Icon(Icons.graphic_eq, color: Colors.blueAccent)
                    : null,
                onTap: () => provider.playSong(song),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }
}
