import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

abstract class QuestionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class UpdateTextAnswer extends QuestionEvent {
  final String text;
  UpdateTextAnswer(this.text);
  
  @override
  List<Object?> get props => [text];
}

class SetAudioPath extends QuestionEvent {
  final String? path;
  SetAudioPath(this.path);
  
  @override
  List<Object?> get props => [path];
}

class SetVideoPath extends QuestionEvent {
  final String? path;
  SetVideoPath(this.path);
  
  @override
  List<Object?> get props => [path];
}

class DeleteAudio extends QuestionEvent {}

class DeleteVideo extends QuestionEvent {}

class SetAudioDuration extends QuestionEvent {
  final int duration;
  SetAudioDuration(this.duration);
  
  @override
  List<Object?> get props => [duration];
}

class QuestionState extends Equatable {
  final String textAnswer;
  final String? audioPath;
  final String? videoPath;
  final int audioDuration;

  const QuestionState({
    this.textAnswer = '',
    this.audioPath,
    this.videoPath,
    this.audioDuration = 0,
  });

  QuestionState copyWith({
    String? textAnswer,
    String? audioPath,
    String? videoPath,
    int? audioDuration,
    bool clearAudio = false,
    bool clearVideo = false,
  }) {
    return QuestionState(
      textAnswer: textAnswer ?? this.textAnswer,
      audioPath: clearAudio ? null : (audioPath ?? this.audioPath),
      videoPath: clearVideo ? null : (videoPath ?? this.videoPath),
      audioDuration: clearAudio ? 0 : (audioDuration ?? this.audioDuration),
    );
  }

  @override
  List<Object?> get props => [textAnswer, audioPath, videoPath, audioDuration];
}

class QuestionBloc extends Bloc<QuestionEvent, QuestionState> {
  QuestionBloc() : super(const QuestionState()) {
    on<UpdateTextAnswer>(_onUpdateTextAnswer);
    on<SetAudioPath>(_onSetAudioPath);
    on<SetVideoPath>(_onSetVideoPath);
    on<DeleteAudio>(_onDeleteAudio);
    on<DeleteVideo>(_onDeleteVideo);
    on<SetAudioDuration>(_onSetAudioDuration);
  }

  void _onUpdateTextAnswer(
    UpdateTextAnswer event,
    Emitter<QuestionState> emit,
  ) {
    emit(state.copyWith(textAnswer: event.text));
  }

  void _onSetAudioPath(
    SetAudioPath event,
    Emitter<QuestionState> emit,
  ) {
    emit(state.copyWith(audioPath: event.path));
  }

  void _onSetVideoPath(
    SetVideoPath event,
    Emitter<QuestionState> emit,
  ) {
    emit(state.copyWith(videoPath: event.path));
  }

  void _onDeleteAudio(
    DeleteAudio event,
    Emitter<QuestionState> emit,
  ) {
    emit(state.copyWith(clearAudio: true));
  }

  void _onDeleteVideo(
    DeleteVideo event,
    Emitter<QuestionState> emit,
  ) {
    emit(state.copyWith(clearVideo: true));
  }

  void _onSetAudioDuration(
    SetAudioDuration event,
    Emitter<QuestionState> emit,
  ) {
    emit(state.copyWith(audioDuration: event.duration));
  }
}