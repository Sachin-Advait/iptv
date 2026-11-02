class ApiConstants {
  static const String wsUrl = "wss://iptvapi.smartsuite.me/iptv/api/ws";

  // static const String baseUrl = "http://192.168.1.199:8090/iptv/api";
  // static const String wsUrl = "ws://192.168.1.199:8090/iptv/api/ws";

  // Home
  static const String layout =
      'https://iptvapi.smartsuite.me/iptv/api/player/config';

  static const String media =
      'https://iptvapi.smartsuite.me/iptv/api/media/category';

  // Category
  static const String home = '$media/Home';
  static const String live = '$media/Live TV';
  static const String vod = '$media/VOD';
  static const String catchUp = '$media/Catch-UP';
  static const String register =
      'https://iptvapi.smartsuite.me/iptv/api/player/register';

  // Announcements currently live (active and inside their display window)
  static const String announcements =
      'https://iptvapi.smartsuite.me/iptv/api/announcements/active';

  // TV Display API
  static const String tvDisplay =
      "https://serveiqbackend.insyncproducts.online/serveiq/api/tv-display/branch/";
  static const String tvContent =
      "https://serveiqbackend.insyncproducts.online/serveiq/api/tv-content/";

  static const String meetingWsUrl =
      "wss://spacehubbackend.insyncproducts.online/spacehub/ws";

  static const String meetingTvDisplay =
      'https://spacehubbackend.insyncproducts.online/spacehub/api/tv-display';
}
