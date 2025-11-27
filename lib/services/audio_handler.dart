import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();

  AudioPlayerHandler() {
    _player.onPlayerStateChanged.listen((state) {
      _broadcastState(state);
    });

    _player.onDurationChanged.listen((duration) {
      final oldItem = mediaItem.value;
      if (oldItem != null) {
        mediaItem.add(oldItem.copyWith(duration: duration));
      }
    });

    _player.onPositionChanged.listen((position) {
      _broadcastState(_player.state);
    });
  }

  void _broadcastState(PlayerState playerState) {
    final playing = playerState == PlayerState.playing;
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          PlayerState.stopped: AudioProcessingState.idle,
          PlayerState.playing: AudioProcessingState.ready,
          PlayerState.paused: AudioProcessingState.ready,
          PlayerState.completed: AudioProcessingState.completed,
        }[playerState]!,
        playing: playing,
        updatePosition: Duration.zero,
        bufferedPosition: Duration.zero,
        speed: 1.0,
        queueIndex: 0,
      ),
    );
  }

  @override
  Future<void> play() => _player.resume();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> playUrl(String url, MediaItem item) async {
    mediaItem.add(item);
    if (url.startsWith('http')) {
      await _player.play(UrlSource(url));
    } else {
      await _player.play(DeviceFileSource(url));
    }
  }

  // Expose player for direct access if needed (though discouraged)
  AudioPlayer get player => _player;
}
