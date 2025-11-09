import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import '../constants/app_constants.dart';

class AudioRecorderWidget extends StatefulWidget {
  final String? audioPath;
  final int audioDuration;
  final VoidCallback onDelete;

  const AudioRecorderWidget({
    Key? key,
    required this.audioPath,
    required this.audioDuration,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveAnimationController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  int _currentPosition = 0;

  @override
  void initState() {
    super.initState();
    _waveAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position.inSeconds;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentPosition = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _waveAnimationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _togglePlayback() async {
    if (widget.audioPath == null) return;

    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_currentPosition > 0) {
        await _audioPlayer.resume();
      } else {
        await _audioPlayer.play(DeviceFileSource(widget.audioPath!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recorded Audio',
                style: AppConstants.smallBold.copyWith(
                  fontFamily: 'Space Grotesk',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: widget.onDelete,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Play/Pause button
              GestureDetector(
                onTap: _togglePlayback,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF5961FF),
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Waveform
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: AnimatedBuilder(
                    animation: _waveAnimationController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: AudioWaveformPainter(
                          animationValue: _isPlaying ? _waveAnimationController.value : 0,
                          color: Colors.white,
                          isStatic: !_isPlaying,
                          progress: widget.audioDuration > 0
                              ? _currentPosition / widget.audioDuration
                              : 0,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Time display
              Text(
                _isPlaying
                    ? _formatTime(_currentPosition)
                    : _formatTime(widget.audioDuration),
                style: AppConstants.smallRegular.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AudioWaveformPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final bool isStatic;
  final double progress;

  AudioWaveformPainter({
    required this.animationValue,
    required this.color,
    this.isStatic = false,
    this.progress = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    const barCount = 40;
    const barWidth = 3.0;
    final spacing = (size.width - (barCount * barWidth)) / (barCount - 1);

    for (int i = 0; i < barCount; i++) {
      final x = i * (barWidth + spacing);
      final barProgress = i / barCount;

      final opacity = progress > 0 && barProgress > progress ? 0.3 : 1.0;

      double height;
      if (isStatic) {
        final staticHeight = math.sin((i / barCount) * math.pi * 4);
        height = (staticHeight.abs() * 0.6 + 0.2) * size.height;
      } else {
        final baseHeight = math.sin((i / barCount) * math.pi * 4 + animationValue * math.pi * 2);
        height = (baseHeight.abs() * 0.6 + 0.2) * size.height;
      }

      paint.color = color.withOpacity(opacity);

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x,
          (size.height - height) / 2,
          barWidth,
          height,
        ),
        const Radius.circular(barWidth / 2),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(AudioWaveformPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isStatic != isStatic ||
        oldDelegate.progress != progress;
  }
}