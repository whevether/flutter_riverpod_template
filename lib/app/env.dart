class Env {
  static const String env = String.fromEnvironment('ENV');
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const String httpPort = String.fromEnvironment('HTTP_PORT');
  static const String socketPort = String.fromEnvironment('SOCKET_PORT');
}