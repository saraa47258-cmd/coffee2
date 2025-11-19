part of 'favorite_bloc.dart';

abstract class FavoriteEvent extends Equatable {
  const FavoriteEvent();

  @override
  List<Object> get props => [];
}

class FavoriteLoadRequested extends FavoriteEvent {}

class FavoriteToggleRequested extends FavoriteEvent {
  final String productId;
  const FavoriteToggleRequested(this.productId);
}

class FavoriteClearAll extends FavoriteEvent {}
