class ApiConfig {
  // CONFIGURACIÓN CORREGIDA PARA DISPOSITIVO FÍSICO
  // Para emulador usar: 'http://10.0.2.2:3002'
  // Para dispositivo físico usar: IP real de tu PC
  static const String baseUrl = 'http://192.168.1.24:3002';
  
  // IPs alternativas por si la principal no funciona
  static const List<String> alternativeIPs = [
    'http://192.168.1.24:3002',
    'http://192.168.56.1:3002',
    'http://192.168.11.1:3002',
    'http://192.168.52.1:3002',
  ];
  
  // Endpoints de la API
  static const String registrarEndpoint = '$baseUrl/api/auth/registrar';
  static const String loginEndpoint = '$baseUrl/api/auth/login';
  static const String socialLoginEndpoint = '$baseUrl/api/social-login';
  static const String messagesEndpoint = '$baseUrl/api/match';

  static String getMessagesUrl(String matchId) {
    return '$messagesEndpoint/$matchId/messages';
  }
}
