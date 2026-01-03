class UserSession {
  static int? userId;

  static bool get isLoggedIn => userId != null;
}
