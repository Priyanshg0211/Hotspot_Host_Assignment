import 'package:flutter/material.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import '../constants/app_constants.dart';

class VideoRecorderWidget extends StatefulWidget {
  final String? videoPath;
  final String? thumbnailPath;
  final int videoDuration;
  final VoidCallback onDelete;

  const VideoRecorderWidget({
    Key? key,
    required this.videoPath,
    required this.thumbnailPath,
    required this.videoDuration,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<VideoRecorderWidget> createState() => _VideoRecorderWidgetState();
}

class _VideoRecorderWidgetState extends State<VideoRecorderWidget> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _isInitialized = false;
      });
    }


    if (widget.videoPath == null || widget.videoPath!.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isInitialized = false;
        });
      }
      return;
    }

    try {
      final file = File(widget.videoPath!);
      
  
      final fileExists = await file.exists();
      if (!fileExists) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isInitialized = false;
          });
        }
        return;
      }


      final stat = await file.stat();
      if (stat.size == 0) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isInitialized = false;
          });
        }
        return;
      }


      _controller = VideoPlayerController.file(file);
      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isInitialized = true;
        });
      }


      _controller!.addListener(_videoListener);

    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isInitialized = false;
        });
      }
      
      if (_controller != null) {
        _controller!.dispose();
        _controller = null;
      }
    }
  }

  void _videoListener() {
    if (!mounted || _controller == null) return;
    
    setState(() {
    });
  }

  void _openFullScreenVideo() {
    if (_controller == null || !_isInitialized) {
      return;
    }

    if (_controller!.value.isPlaying) {
      _controller!.pause();
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenVideoPage(
          controller: _controller!,
          videoPath: widget.videoPath!,
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(VideoRecorderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.videoPath != widget.videoPath) {
      _disposeController();
      _initVideo();
    }
  }

  void _disposeController() {
    if (_controller != null) {
      _controller!.removeListener(_videoListener);
      _controller!.dispose();
      _controller = null;
    }
    _isInitialized = false;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildVideoThumbnail() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: widget.thumbnailPath != null && File(widget.thumbnailPath!).existsSync()
          ? ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.file(
                File(widget.thumbnailPath!),
                fit: BoxFit.cover,
                width: 40,
                height: 40,
              ),
            )
          : Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.videocam,
                color: Colors.white,
                size: 20,
              ),
            ),
    );
  }

  Widget _buildVideoPlayerThumbnail() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: VideoPlayer(_controller!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Video thumbnail with play button
          GestureDetector(
            onTap: _openFullScreenVideo,
            child: Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.white.withOpacity(0.7),
                            strokeWidth: 2,
                          ),
                        )
                      : _isInitialized && _controller != null
                          ? _buildVideoPlayerThumbnail()
                          : _buildVideoThumbnail(),
                ),
                
                // Small play icon overlay
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.black,
                        size: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Video Recorded',
                  style: AppConstants.smallBold.copyWith(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isInitialized && _controller != null
                      ? _formatTime(_controller!.value.duration)
                      : _formatTime(Duration(seconds: widget.videoDuration)),
                  style: AppConstants.smallRegular.copyWith(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          
          GestureDetector(
            onTap: widget.onDelete,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenVideoPage extends StatefulWidget {
  final VideoPlayerController controller;
  final String videoPath;

  const FullScreenVideoPage({
    Key? key,
    required this.controller,
    required this.videoPath,
  }) : super(key: key);

  @override
  State<FullScreenVideoPage> createState() => _FullScreenVideoPageState();
}

class _FullScreenVideoPageState extends State<FullScreenVideoPage> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _showControls = true;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _isPlaying = _controller.value.isPlaying;
    _currentPosition = _controller.value.position;
    _totalDuration = _controller.value.duration;


    _controller.addListener(_videoListener);
    _hideControlsAfterDelay();
  }

  void _videoListener() {
    if (mounted) {
      setState(() {
        _isPlaying = _controller.value.isPlaying;
        _currentPosition = _controller.value.position;
        _totalDuration = _controller.value.duration;
      });
    }
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _togglePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {

        if (_controller.value.position >= _controller.value.duration - const Duration(seconds: 1)) {
          _controller.seekTo(Duration.zero);
        }
        _controller.play();
      }
      _isPlaying = _controller.value.isPlaying;
    });
    _showControlsTemporarily();
  }

  void _showControlsTemporarily() {
    setState(() {
      _showControls = true;
    });
    _hideControlsAfterDelay();
  }

  void _seekToPosition(double value) {
    final newPosition = value * _totalDuration.inMilliseconds;
    _controller.seekTo(Duration(milliseconds: newPosition.round()));
    _showControlsTemporarily();
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onTap: _showControlsTemporarily,
              child: Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),

            if (_showControls)
              Positioned(
                top: 16,
                left: 16,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),

            if (_showControls)
              Positioned.fill(
                child: Center(
                  child: GestureDetector(
                    onTap: _togglePlay,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),

            if (_showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Progress Slider
                      Slider(
                        value: _totalDuration.inMilliseconds > 0
                            ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
                            : 0.0,
                        onChanged: _seekToPosition,
                        onChangeStart: (_) => setState(() {
                          _showControls = true;
                        }),
                        activeColor: const Color(0xFF5961FF),
                        inactiveColor: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 8),
                      // Time Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatTime(_currentPosition),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _formatTime(_totalDuration),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}