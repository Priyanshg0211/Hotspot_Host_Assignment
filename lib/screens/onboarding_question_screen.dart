import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../bloc/question/question_bloc.dart';
import '../widgets/audio_recorder_widget.dart';
import '../widgets/video_recorder_widget.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';

class OnboardingQuestionScreen extends StatefulWidget {
  const OnboardingQuestionScreen({super.key});

  @override
  State<OnboardingQuestionScreen> createState() =>
      _OnboardingQuestionScreenState();
}

class _OnboardingQuestionScreenState extends State<OnboardingQuestionScreen>
    with TickerProviderStateMixin {
  double progress = 0.9;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

  bool _isRecording = false;
  int _recordingSeconds = 0;
  String? _videoThumbnail;
  int _videoDuration = 0;
  double _videoProcessingProgress = 0.0;
  bool _isProcessingVideo = false;

  AnimationController? _waveAnimationController;
  AnimationController? _buttonWidthController;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _textFocusNode.addListener(_onFocusChange);

    _waveAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _buttonWidthController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1.0,
    );
  }

  void _onFocusChange() {
    if (_textFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }

  void _onTextChanged() {
    context.read<QuestionBloc>().add(UpdateTextAnswer(_textController.text));
    setState(() {});
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    _scrollController.dispose();
    _waveAnimationController?.dispose();
    _buttonWidthController?.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _startRecordingTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isRecording && mounted) {
        setState(() {
          _recordingSeconds++;
        });
        _startRecordingTimer();
      }
    });
  }

  Future<void> _handleAudioRecording() async {
    final state = context.read<QuestionBloc>().state;

    if (state.audioPath != null) {
      return;
    }

    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final path =
            '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );

        setState(() {
          _isRecording = true;
          _recordingSeconds = 0;
        });
        _startRecordingTimer();

        AppLogger.info('Audio recording started');
      } catch (e) {
        AppLogger.error('Error starting audio recording', error: e);
        if (mounted) {
          _showErrorSnackBar(
            'Unable to start recording. Please check microphone permissions.',
          );
        }
      }
    } else {
      if (mounted) {
        _showErrorSnackBar(
          'Microphone permission is required to record audio',
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      if (path != null) {
        context.read<QuestionBloc>().add(SetAudioPath(path));
        context.read<QuestionBloc>().add(SetAudioDuration(_recordingSeconds));

        setState(() {
          _isRecording = false;
        });

        _animateButtonWidth();

        AppLogger.info('Audio recorded', data: {
          'path': path,
          'duration': _recordingSeconds,
        });
      }
    } catch (e) {
      AppLogger.error('Error stopping recording', error: e);
      setState(() {
        _isRecording = false;
      });
    }
  }

  void _handleVideoInput() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.videocam, color: Colors.white),
                title: Text(
                  'Record Video',
                  style: AppConstants.smallRegular.copyWith(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _recordVideo();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: Text(
                  'Choose from Gallery',
                  style: AppConstants.smallRegular.copyWith(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideoFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _recordVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 2),
      );

      if (video != null) {
        await _processVideo(video);
      }
    } catch (e) {
      AppLogger.error('Video recording error', error: e);
      _showErrorSnackBar('Failed to record video. Please try again.');
    }
  }

  Future<void> _pickVideoFromGallery() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        await _processVideo(video);
      }
    } catch (e) {
      AppLogger.error('Video gallery error', error: e);
      _showErrorSnackBar('Failed to pick video. Please try again.');
    }
  }

  Future<void> _processVideo(XFile video) async {
    setState(() {
      _isProcessingVideo = true;
      _videoProcessingProgress = 0.0;
    });

    try {
      final videoFile = File(video.path);
      if (!await videoFile.exists()) {
        throw Exception('Video file does not exist');
      }

      final stat = await videoFile.stat();
      if (stat.size == 0) {
        throw Exception('Video file is empty');
      }

      AppLogger.info('Processing video', data: {
        'path': video.path,
        'size': stat.size,
      });

      setState(() => _videoProcessingProgress = 0.3);

      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: video.path,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.JPEG,
        quality: 50,
      );

      if (thumbnailPath == null) {
        throw Exception('Failed to generate thumbnail');
      }

      setState(() => _videoProcessingProgress = 0.6);

      final videoController = VideoPlayerController.file(videoFile);
      await videoController.initialize();
      final duration = videoController.value.duration.inSeconds;
      videoController.dispose();

      setState(() => _videoProcessingProgress = 0.9);

      if (mounted) {
        context.read<QuestionBloc>().add(SetVideoPath(video.path));
        setState(() {
          _videoThumbnail = thumbnailPath;
          _videoDuration = duration;
          _isProcessingVideo = false;
          _videoProcessingProgress = 1.0;
        });

        _animateButtonWidth();

        AppLogger.info('Video processed successfully', data: {
          'duration': duration,
          'thumbnail': thumbnailPath,
        });
      }
    } catch (e, stackTrace) {
      AppLogger.error('Video processing error', error: e, stackTrace: stackTrace);

      setState(() {
        _isProcessingVideo = false;
        _videoProcessingProgress = 0.0;
      });

      if (mounted) {
        _showErrorSnackBar(
          'Failed to process video. Please ensure the video is valid and try again.',
        );
      }
    }
  }

  void _animateButtonWidth() {
    _buttonWidthController?.forward(from: 0.0);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _handleNext() {
    final state = context.read<QuestionBloc>().state;

    AppLogger.info('Onboarding completed', data: {
      'textAnswer': state.textAnswer,
      'hasAudio': state.audioPath != null,
      'audioDuration': state.audioDuration,
      'hasVideo': state.videoPath != null,
    });

    _showSuccessSnackBar('Onboarding Complete! Your response has been saved.');
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: BlocBuilder<QuestionBloc, QuestionState>(
                  builder: (context, state) {
                    return _buildContent(state, isKeyboardOpen, screenHeight);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    QuestionState state,
    bool isKeyboardOpen,
    double screenHeight,
  ) {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const ClampingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom -
              80,
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 24.0,
            bottom: 24.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: isKeyboardOpen ? 20 : 40),
              Text(
                '03',
                style: AppConstants.smallRegular.copyWith(
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Why do you want to host with us?',
                style: AppConstants.bodyBold.copyWith(
                  color: Colors.white,
                  fontSize: isKeyboardOpen ? 18 : 24,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Tell us about your intent and what motivates you to create experiences.',
                style: AppConstants.smallRegular.copyWith(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: isKeyboardOpen ? 12 : 16,
                ),
              ),
              const SizedBox(height: 24),
              _buildTextArea(isKeyboardOpen),
              const SizedBox(height: 24),
              if (_isRecording) ...[
                _buildRecordingInProgress(),
                const SizedBox(height: 24),
              ],
              if (_isProcessingVideo) ...[
                _buildVideoProcessing(),
                const SizedBox(height: 24),
              ],
              if (state.audioPath != null && !_isRecording) ...[
                AudioRecorderWidget(
                  audioPath: state.audioPath,
                  audioDuration: state.audioDuration,
                  onDelete: () {
                    context.read<QuestionBloc>().add(DeleteAudio());
                    _animateButtonWidth();
                  },
                ),
                const SizedBox(height: 24),
              ],
              if (state.videoPath != null && !_isProcessingVideo) ...[
                VideoRecorderWidget(
                  videoPath: state.videoPath,
                  thumbnailPath: _videoThumbnail,
                  videoDuration: _videoDuration,
                  onDelete: () {
                    context.read<QuestionBloc>().add(DeleteVideo());
                    setState(() {
                      _videoThumbnail = null;
                      _videoDuration = 0;
                    });
                    _animateButtonWidth();
                  },
                ),
                const SizedBox(height: 24),
              ],
              _buildButtonsRow(state),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoProcessing() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Processing Video...',
            style: AppConstants.smallBold.copyWith(
              fontFamily: 'Space Grotesk',
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _videoProcessingProgress,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5961FF)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(_videoProcessingProgress * 100).toInt()}% complete',
            style: AppConstants.smallRegular.copyWith(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingInProgress() {
    return Container(
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
                'Recording Audio...',
                style: AppConstants.smallBold.copyWith(
                  fontFamily: 'Space Grotesk',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: _stopRecording,
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
              GestureDetector(
                onTap: _stopRecording,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF5961FF),
                  ),
                  child: const Icon(Icons.stop, color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: AnimatedBuilder(
                    animation: _waveAnimationController!,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: RecordingWaveformPainter(
                          animationValue: _waveAnimationController!.value,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                _formatTime(_recordingSeconds),
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

  Widget _buildTextArea(bool isKeyboardOpen) {
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    double textFieldHeight;
    if (isKeyboardOpen) {
      textFieldHeight = math.max(100, availableHeight * 0.15);
    } else {
      textFieldHeight = math.max(200, availableHeight * 0.30);
    }

    final currentLength = _textController.text.length;
    final maxLength = 600;
    final isNearLimit = currentLength > maxLength * 0.8;
    final isAtLimit = currentLength >= maxLength;

    return Column(
      children: [
        Container(
          height: textFieldHeight,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isAtLimit
                  ? Colors.orange.withOpacity(0.5)
                  : Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _textController,
            focusNode: _textFocusNode,
            maxLines: null,
            maxLength: maxLength,
            style: AppConstants.smallRegular.copyWith(
              color: Colors.white,
              fontSize: isKeyboardOpen ? 14 : 16,
            ),
            decoration: InputDecoration(
              hintText: '/ Start typing here',
              hintStyle: AppConstants.smallRegular.copyWith(
                color: Colors.white.withOpacity(0.3),
                fontSize: isKeyboardOpen ? 14 : 16,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
              counter: const SizedBox.shrink(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isAtLimit
                  ? Colors.orange.withOpacity(0.2)
                  : isNearLimit
                      ? Colors.white.withOpacity(0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$currentLength/$maxLength',
              style: AppConstants.lowercaseRegular.copyWith(
                color: isAtLimit
                    ? Colors.orange
                    : isNearLimit
                        ? Colors.white.withOpacity(0.9)
                        : Colors.white.withOpacity(0.5),
                fontSize: 12,
                fontWeight: isNearLimit ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtonsRow(QuestionState state) {
    final bool showAudioButton = state.audioPath == null && !_isRecording;
    final bool showVideoButton = state.videoPath == null && !_isProcessingVideo;
    final bool showAnyButton = showAudioButton || showVideoButton;

    return AnimatedBuilder(
      animation: _buttonWidthController!,
      builder: (context, child) {
        return Row(
          children: [
            if (showAnyButton)
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: const Color(0xff101010),
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (showAudioButton) ...[
                            GestureDetector(
                              onTap: _handleAudioRecording,
                              child: const Icon(
                                Icons.mic_none_outlined,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ],
                          if (showAudioButton && showVideoButton) ...[
                            const SizedBox(width: 20),
                            Container(
                              width: 1,
                              height: 20,
                              color: Colors.white.withOpacity(0.2),
                            ),
                            const SizedBox(width: 20),
                          ],
                          if (showVideoButton)
                            GestureDetector(
                              onTap: _handleVideoInput,
                              child: const Icon(
                                Icons.videocam_outlined,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (showAnyButton)
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                width: 12,
              ),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                child: _buildNextButton(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNextButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF101010),
            const Color(0xFF1A1A1A),
            const Color(0xFFFFFFFF).withOpacity(0.05),
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: const RadialGradient(
              center: Alignment(0.0, -0.8),
              radius: 1.5,
              colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
              stops: [0.0, 1.0],
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleNext,
              borderRadius: BorderRadius.circular(8),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Next',
                      style: AppConstants.smallRegular.copyWith(
                        fontFamily: 'Space Grotesk',
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SvgPicture.asset(
                      'assets/icon/arrow.svg',
                      width: 15,
                      height: 15,
                      colorFilter: ColorFilter.mode(
                        Colors.white.withOpacity(0.9),
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.02)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 8,
                    child: CustomPaint(
                      painter: WaveProgressPainter(
                        progress: progress,
                        activeColor: const Color(0xFF5B7FFF),
                        inactiveColor: Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RecordingWaveformPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  RecordingWaveformPainter({required this.animationValue, required this.color});

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

      final baseHeight = math.sin(
        (i / barCount) * math.pi * 4 + animationValue * math.pi * 2,
      );
      final height = (baseHeight.abs() * 0.6 + 0.2) * size.height;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, (size.height - height) / 2, barWidth, height),
        const Radius.circular(barWidth / 2),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(RecordingWaveformPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class WaveProgressPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color inactiveColor;

  WaveProgressPainter({
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    const waveLength = 16.0;
    const amplitude = 2.5;
    final centerY = size.height / 2;

    final path = Path();
    path.moveTo(0, centerY);

    double x = 0;
    while (x <= size.width) {
      final y = centerY + amplitude * math.sin((x / waveLength) * 2 * math.pi);
      path.lineTo(x, y);
      x += 0.5;
    }

    paint.color = inactiveColor;
    canvas.drawPath(path, paint);

    if (progress > 0) {
      paint.color = activeColor;
      final progressWidth = size.width * progress;

      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, progressWidth, size.height));
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(WaveProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor;
  }
}