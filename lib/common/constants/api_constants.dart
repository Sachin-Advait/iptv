class ApiConstants {
  static const String baseUrl = "https://iptvapi.smartsuite.me/iptv/api";
  static const String wsUrl = "wss://iptvapi.smartsuite.me/iptv/api/ws";

  // static const String baseUrl = "http://192.168.1.199:8090/iptv/api";
  // static const String wsUrl = "ws://192.168.1.199:8090/iptv/api/ws";

  // Home
  static const String media = '/media/category';
  static const String layout = '/player/config';

  // Category
  static const String home = '$media/Home';
  static const String live = '$media/Live TV';
  static const String vod = '$media/VOD';
  static const String catchUp = '$media/Catch-UP';
  static const String register = '/player/register';
}
