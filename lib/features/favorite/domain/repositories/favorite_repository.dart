abstract class FavoriteRepository {
  Future<Set<String>> fetchFavorites();
  Future<void> setFavorite(String productId, bool isFavorite);
  Future<void> clearFavorites();
}

