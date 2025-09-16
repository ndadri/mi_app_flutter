class ApiConfig {
  // Cambia esta línea según tu entorno:
  // Para emulador Android usa:
  // static const String baseUrl = 'http://10.0.2.2:3002';
  // Para dispositivo físico usa la IP real de tu PC:
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
