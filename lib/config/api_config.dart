class ApiConfig {
  // Para el emulador de Android, usa 10.0.2.2 que mapea al localhost de la máquina host
  // Para dispositivo físico: usa la IP de tu red local (ejemplo: 192.168.1.24)
  // Para navegador web: usa 'localhost'
  
  // URL base para desarrollo local
  static const String baseUrl = 'http://192.168.1.24:3002';
  
  // Endpoints de la API
  static const String registrarEndpoint = '$baseUrl/api/registrar';
  static const String loginEndpoint = '$baseUrl/api/login';
  static const String messagesEndpoint = '$baseUrl/api/match';
  
  // Para obtener la URL completa de mensajes
  static String getMessagesUrl(String matchId) {
    return '$messagesEndpoint/$matchId/messages';
  }
}
