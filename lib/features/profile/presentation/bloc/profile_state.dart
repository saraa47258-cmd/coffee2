part of 'profile_bloc.dart';

class ProfileState extends Equatable {
  final Profile? profile;
  final bool loading;
  final String? error;

  const ProfileState({this.profile, this.loading = false, this.error});

  factory ProfileState.initial() =>
      const ProfileState(profile: null, loading: false);

  ProfileState copyWith({Profile? profile, bool? loading, String? error}) {
    return ProfileState(
      profile: profile ?? this.profile,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [profile, loading, error];
}
