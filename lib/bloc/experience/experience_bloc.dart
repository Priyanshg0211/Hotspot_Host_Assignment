import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/experience_model.dart';
import '../../data/repositories/experience_repository.dart';

abstract class ExperienceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadExperiences extends ExperienceEvent {}

class ToggleExperienceSelection extends ExperienceEvent {
  final int experienceId;
  ToggleExperienceSelection(this.experienceId);
  
  @override
  List<Object?> get props => [experienceId];
}

class UpdateDescription extends ExperienceEvent {
  final String description;
  UpdateDescription(this.description);
  
  @override
  List<Object?> get props => [description];
}

class ReorderExperiences extends ExperienceEvent {
  final int experienceId;
  ReorderExperiences(this.experienceId);
  
  @override
  List<Object?> get props => [experienceId];
}

abstract class ExperienceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExperienceInitial extends ExperienceState {}

class ExperienceLoading extends ExperienceState {}

class ExperienceLoaded extends ExperienceState {
  final List<Experience> experiences;
  final Set<int> selectedIds;
  final String description;

  ExperienceLoaded({
    required this.experiences,
    this.selectedIds = const {},
    this.description = '',
  });

  ExperienceLoaded copyWith({
    List<Experience>? experiences,
    Set<int>? selectedIds,
    String? description,
  }) {
    return ExperienceLoaded(
      experiences: experiences ?? this.experiences,
      selectedIds: selectedIds ?? this.selectedIds,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [experiences, selectedIds, description];
}

class ExperienceError extends ExperienceState {
  final String message;
  ExperienceError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class ExperienceBloc extends Bloc<ExperienceEvent, ExperienceState> {
  final ExperienceRepository repository;

  ExperienceBloc({required this.repository}) : super(ExperienceInitial()) {
    on<LoadExperiences>(_onLoadExperiences);
    on<ToggleExperienceSelection>(_onToggleSelection);
    on<UpdateDescription>(_onUpdateDescription);
    on<ReorderExperiences>(_onReorderExperiences);
  }

  Future<void> _onLoadExperiences(
    LoadExperiences event,
    Emitter<ExperienceState> emit,
  ) async {
    emit(ExperienceLoading());
    try {
      final experiences = await repository.fetchExperiences();
      emit(ExperienceLoaded(experiences: experiences));
    } catch (e) {
      emit(ExperienceError(e.toString()));
    }
  }

  void _onToggleSelection(
    ToggleExperienceSelection event,
    Emitter<ExperienceState> emit,
  ) {
    if (state is ExperienceLoaded) {
      final currentState = state as ExperienceLoaded;
      final selectedIds = Set<int>.from(currentState.selectedIds);
      
      if (selectedIds.contains(event.experienceId)) {
        selectedIds.remove(event.experienceId);
      } else {
        selectedIds.add(event.experienceId);
      }
      
      emit(currentState.copyWith(selectedIds: selectedIds));
    }
  }

  void _onUpdateDescription(
    UpdateDescription event,
    Emitter<ExperienceState> emit,
  ) {
    if (state is ExperienceLoaded) {
      final currentState = state as ExperienceLoaded;
      emit(currentState.copyWith(description: event.description));
    }
  }

  void _onReorderExperiences(
    ReorderExperiences event,
    Emitter<ExperienceState> emit,
  ) {
    if (state is ExperienceLoaded) {
      final currentState = state as ExperienceLoaded;
      final experiences = List<Experience>.from(currentState.experiences);
      
      final selectedIndex = experiences.indexWhere((exp) => exp.id == event.experienceId);
      if (selectedIndex != -1 && selectedIndex != 0) {
        final selectedExperience = experiences.removeAt(selectedIndex);
        experiences.insert(0, selectedExperience);
        
        emit(currentState.copyWith(experiences: experiences));
      }
    }
  }
}