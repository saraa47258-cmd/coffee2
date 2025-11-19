import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'favorite_event.dart';
part 'favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  FavoriteBloc() : super(FavoriteState.initial()) {
    on<FavoriteLoadRequested>((e, emit) {
      emit(FavoriteState.initial());
    });

    on<FavoriteToggleRequested>((e, emit) {
      final current = Set<String>.from(state.favoriteIds);
      if (current.contains(e.productId)) {
        current.remove(e.productId);
      } else {
        current.add(e.productId);
      }
      emit(state.copyWith(favoriteIds: current));
    });

    on<FavoriteClearAll>((e, emit) {
      emit(state.copyWith(favoriteIds: <String>{}));
    });
  }
}
