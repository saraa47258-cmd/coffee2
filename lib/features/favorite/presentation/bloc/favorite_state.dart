part of 'favorite_bloc.dart';

class FavoriteState extends Equatable {
  final Set<String> favoriteIds;

  const FavoriteState({required this.favoriteIds});

  factory FavoriteState.initial() =>
      const FavoriteState(favoriteIds: <String>{});

  FavoriteState copyWith({Set<String>? favoriteIds}) =>
      FavoriteState(favoriteIds: favoriteIds ?? this.favoriteIds);

  @override
  List<Object> get props => [favoriteIds];
}
