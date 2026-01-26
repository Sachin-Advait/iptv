class ApiConstants {
  static const String baseUrl =
      "https://serveiqbackend.insyncproducts.online/serveiq/api/";
  // static const String baseUrl = "http://192.168.1.121:8085/serveiq/api/";

  // Auth
  static const String login = 'auth/login';

  // Services
  static const String mainServices = 'services/branch/main/';
  static const String subServices = 'services/subservices/';
  static const String category = 'categories';

  // Tokens
  static const String generateToken = 'tokens/generate';

  // Whatsapp
  static const String sendWhatsapp = 'whatsapp/send';

  // Visitor
  static const String visitors = 'visitors/';
}
