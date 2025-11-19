import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ty_cafe/features/favorite/domain/repositories/favorite_repository.dart';

part 'favorite_event.dart';
part 'favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final FavoriteRepository repository;

  FavoriteBloc({required this.repository}) : super(FavoriteState.initial()) {
    on<FavoriteLoadRequested>(_onLoad);
    on<FavoriteToggleRequested>(_onToggle);
    on<FavoriteClearAll>(_onClear);
  }

  Future<void> _onLoad(
    FavoriteLoadRequested event,
    Emitter<FavoriteState> emit,
  ) async {
    final ids = await repository.fetchFavorites();
    emit(state.copyWith(favoriteIds: ids));
  }

  Future<void> _onToggle(
    FavoriteToggleRequested event,
    Emitter<FavoriteState> emit,
  ) async {
    final updated = Set<String>.from(state.favoriteIds);
    final shouldAdd = !updated.contains(event.productId);
    if (shouldAdd) {
      updated.add(event.productId);
    } else {
      updated.remove(event.productId);
    }
    emit(state.copyWith(favoriteIds: updated));
    await repository.setFavorite(event.productId, shouldAdd);
  }

  Future<void> _onClear(
    FavoriteClearAll event,
    Emitter<FavoriteState> emit,
  ) async {
    await repository.clearFavorites();
    emit(state.copyWith(favoriteIds: <String>{}));
  }
}
