class ApiConstants {
  static const String baseUrl = "http://109.205.180.193:8090/iptv/api";
  static const String wsUrl = "ws://109.205.180.193:8090/iptv/api/ws";

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
