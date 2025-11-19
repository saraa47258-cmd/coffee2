import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ty_cafe/features/profile/data/repositories/profile_repository.dart';
import 'package:ty_cafe/features/profile/domain/entities/profile.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;
  ProfileBloc({required this.repository}) : super(ProfileState.initial()) {
    on<ProfileLoadRequested>(_onLoad);
    on<ProfileUpdateRequested>(_onUpdate);
    on<ProfileClearRequested>(_onClear);
  }

  Future<void> _onLoad(ProfileLoadRequested e, Emitter emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final p = await repository.loadProfile();
      emit(state.copyWith(profile: p, loading: false));
    } catch (err) {
      emit(state.copyWith(loading: false, error: err.toString()));
    }
  }

  Future<void> _onUpdate(ProfileUpdateRequested e, Emitter emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await repository.saveProfile(e.profile);
      emit(state.copyWith(profile: e.profile, loading: false));
    } catch (err) {
      emit(state.copyWith(loading: false, error: err.toString()));
    }
  }

  Future<void> _onClear(ProfileClearRequested e, Emitter emit) async {
    await repository.clearProfile();
    emit(ProfileState.initial());
  }
}
