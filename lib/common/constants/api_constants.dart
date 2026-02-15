class ApiConstants {
  static const String baseUrl = "http://iptvapi.smartsuite.me/api";
  static const String wsUrl = "wss://iptvapi.smartsuite.me/api/iptv/ws";

  // Home
  static const String media = '/media/category';
  static const String tickers = '/news/published/titles';

  // Category
  static const String home = '$media/Home';
  static const String live = '$media/Live TV';
  static const String vod = '$media/VOD';
  static const String catchUp = '$media/Catch-UP';
  static const String register = '/player/register';
}
