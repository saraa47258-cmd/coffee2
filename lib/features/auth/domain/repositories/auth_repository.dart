abstract class AuthRepository {
  Future<String?> signInWithEmailAndPassword(String email, String password);
  Future<String?> signUpWithEmailAndPassword(
    String email,
    String password, {
    String role = 'user',
  });
  Future<void> signOut();
  Future<String?> getCurrentUserId();
  Future<String?> getUserRole(String userId);
}

