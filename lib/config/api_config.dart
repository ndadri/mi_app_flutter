class ApiConfig {
  // Cambia esta IP por la de tu PC si usas dispositivo físico, o usa 10.0.2.2 para emulador Android
static const String baseUrl = 'http://10.0.2.2:3002';
  // Endpoints de la API
  static const String registrarEndpoint = '$baseUrl/api/auth/registrar';
  static const String loginEndpoint = '$baseUrl/api/auth/login';
  static const String socialLoginEndpoint = '$baseUrl/api/social-login';
  static const String messagesEndpoint = '$baseUrl/api/match';

  static String getMessagesUrl(String matchId) {
    return '$messagesEndpoint/$matchId/messages';
  }
}
