part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {}

class ProfileUpdateRequested extends ProfileEvent {
  final Profile profile;
  const ProfileUpdateRequested(this.profile);
}

class ProfileClearRequested extends ProfileEvent {}
