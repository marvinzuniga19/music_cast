import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/music_provider.dart';
import '../widgets/cast_device_selector.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MusicProvider>(context);
    // Manejo de seguridad por si acaso se abre sin canción (edge case)
    if (provider.currentSong == null) {
      return const Scaffold(
        body: Center(child: Text("No hay canción seleccionada")),
      );
    }

    final song = provider.currentSong!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reproduciendo'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Arte del Álbum
            Expanded(
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: song.albumArt,
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.width * 0.8,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Título y Artista
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      song.artist,
                      style: TextStyle(fontSize: 18, color: Colors.grey[400]),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.favorite_border, size: 28),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Barra de Progreso
            Column(
              children: [
                Slider(
                  value: provider.position.inSeconds.toDouble().clamp(
                    0.0,
                    provider.duration.inSeconds.toDouble(),
                  ),
                  max: provider.duration.inSeconds.toDouble() > 0
                      ? provider.duration.inSeconds.toDouble()
                      : 1.0,
                  activeColor: Colors.white,
                  inactiveColor: Colors.grey[800],
                  onChanged: (value) {
                    provider.seek(Duration(seconds: value.toInt()));
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(provider.position),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        _formatDuration(provider.duration),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Controles de Reproducción
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.shuffle, color: Colors.grey),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.replay_10),
                  onPressed: () {
                    final newPos =
                        provider.position - const Duration(seconds: 10);
                    provider.seek(
                      newPos < Duration.zero ? Duration.zero : newPos,
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_previous, size: 40),
                  onPressed: () => provider.previous(),
                ),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: IconButton(
                    iconSize: 40,
                    icon: Icon(
                      provider.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      provider.isPlaying ? provider.pause() : provider.resume();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, size: 40),
                  onPressed: () => provider.next(),
                ),
                IconButton(
                  icon: const Icon(Icons.forward_10),
                  onPressed: () {
                    final newPos =
                        provider.position + const Duration(seconds: 10);
                    final maxDur = provider.duration;
                    provider.seek(newPos > maxDur ? maxDur : newPos);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.repeat, color: Colors.grey),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Botón de Dispositivos (Cast)
            TextButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: const Color(0xFF282828),
                  builder: (ctx) => const CastDeviceSelector(),
                );
              },
              icon: Icon(
                provider.isCasting ? Icons.tv : Icons.speaker,
                color: provider.isCasting ? Colors.blueAccent : Colors.grey,
              ),
              label: Text(
                provider.isCasting
                    ? 'Conectado a ${provider.connectedDeviceName}'
                    : 'Dispositivos disponibles',
                style: TextStyle(
                  color: provider.isCasting ? Colors.blueAccent : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
