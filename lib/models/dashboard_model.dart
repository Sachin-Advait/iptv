class DashboardModel {
  bool success;
  String message;
  DashboardDetails data;

  DashboardModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
    success: json["success"],
    message: json["message"],
    data: DashboardDetails.fromJson(json["data"]),
  );
}

class DashboardDetails {
  String deviceId;
  String profileName;
  Layout layout;
  List<BannerZoneElement> videoZone;
  List<BannerZoneElement> bannerZone;
  List<ChannelZone> channelZone;
  List<TickerZone> tickerZone;

  DashboardDetails({
    required this.deviceId,
    required this.profileName,
    required this.layout,
    required this.videoZone,
    required this.bannerZone,
    required this.channelZone,
    required this.tickerZone,
  });

  factory DashboardDetails.fromJson(Map<String, dynamic> json) =>
      DashboardDetails(
        deviceId: json["deviceId"],
        profileName: json["profileName"],
        layout: Layout.fromJson(json["layout"]),
        videoZone: List<BannerZoneElement>.from(
          json["videoZone"].map((x) => BannerZoneElement.fromJson(x)),
        ),
        bannerZone: List<BannerZoneElement>.from(
          json["bannerZone"].map((x) => BannerZoneElement.fromJson(x)),
        ),
        channelZone: List<ChannelZone>.from(
          json["channelZone"].map((x) => ChannelZone.fromJson(x)),
        ),
        tickerZone: List<TickerZone>.from(
          json["tickerZone"].map((x) => TickerZone.fromJson(x)),
        ),
      );
}

class BannerZoneElement {
  int id;
  String title;
  String category;
  List<String>? imageUrls;
  String? videoUrl;

  BannerZoneElement({
    required this.id,
    required this.title,
    required this.category,
    this.imageUrls,
    this.videoUrl,
  });

  factory BannerZoneElement.fromJson(Map<String, dynamic> json) =>
      BannerZoneElement(
        id: json["id"],
        title: json["title"],
        category: json["category"],
        imageUrls: json["imageUrls"] == null
            ? []
            : List<String>.from(json["imageUrls"]!.map((x) => x)),
        videoUrl: json["videoUrl"],
      );
}

class ChannelZone {
  int id;
  String channelGroupName;
  int displayOrder;
  dynamic logoUrl;
  List<Channel> channels;

  ChannelZone({
    required this.id,
    required this.channelGroupName,
    required this.displayOrder,
    required this.logoUrl,
    required this.channels,
  });

  factory ChannelZone.fromJson(Map<String, dynamic> json) => ChannelZone(
    id: json["id"],
    channelGroupName: json["channelGroupName"],
    displayOrder: json["displayOrder"],
    logoUrl: json["logoUrl"],
    channels: List<Channel>.from(
      json["channels"].map((x) => Channel.fromJson(x)),
    ),
  );
}

class Channel {
  int id;
  String name;
  String type;
  String streamUrl;
  String language;
  String logoUrl;
  dynamic logoIcon;
  int displayOrder;

  Channel({
    required this.id,
    required this.name,
    required this.type,
    required this.streamUrl,
    required this.language,
    required this.logoUrl,
    required this.logoIcon,
    required this.displayOrder,
  });

  factory Channel.fromJson(Map<String, dynamic> json) => Channel(
    id: json["id"],
    name: json["name"],
    type: json["type"],
    streamUrl: json["streamUrl"],
    language: json["language"],
    logoUrl: json["logoUrl"],
    logoIcon: json["logoIcon"],
    displayOrder: json["displayOrder"],
  );
}

class Layout {
  int id;
  String name;
  String layoutType;
  String orientation;
  bool videoEnabled;
  bool bannerEnabled;
  bool channelEnabled;
  bool tickerEnabled;
  ConfigJson configJson;

  Layout({
    required this.id,
    required this.name,
    required this.layoutType,
    required this.orientation,
    required this.videoEnabled,
    required this.bannerEnabled,
    required this.channelEnabled,
    required this.tickerEnabled,
    required this.configJson,
  });

  factory Layout.fromJson(Map<String, dynamic> json) => Layout(
    id: json["id"],
    name: json["name"],
    layoutType: json["layoutType"],
    orientation: json["orientation"],
    videoEnabled: json["videoEnabled"],
    bannerEnabled: json["bannerEnabled"],
    channelEnabled: json["channelEnabled"],
    tickerEnabled: json["tickerEnabled"],
    configJson: ConfigJson.fromJson(json["configJson"]),
  );
}

class ConfigJson {
  ChannelZoneClass videoZone;
  ChannelZoneClass bannerZone;
  ChannelZoneClass tickerZone;
  ChannelZoneClass channelZone;

  ConfigJson({
    required this.videoZone,
    required this.bannerZone,
    required this.tickerZone,
    required this.channelZone,
  });

  factory ConfigJson.fromJson(Map<String, dynamic> json) => ConfigJson(
    videoZone: ChannelZoneClass.fromJson(json["videoZone"]),
    bannerZone: ChannelZoneClass.fromJson(json["bannerZone"]),
    tickerZone: ChannelZoneClass.fromJson(json["tickerZone"]),
    channelZone: ChannelZoneClass.fromJson(json["channelZone"]),
  );
}

class ChannelZoneClass {
  int x;
  int y;
  int width;
  int height;
  String? position;

  ChannelZoneClass({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.position,
  });

  factory ChannelZoneClass.fromJson(Map<String, dynamic> json) =>
      ChannelZoneClass(
        x: json["x"],
        y: json["y"],
        width: json["width"],
        height: json["height"],
        position: json["position"],
      );
}

class TickerZone {
  int id;
  String title;
  String summary;
  String link;

  TickerZone({
    required this.id,
    required this.title,
    required this.summary,
    required this.link,
  });

  factory TickerZone.fromJson(Map<String, dynamic> json) => TickerZone(
    id: json["id"],
    title: json["title"],
    summary: json["summary"],
    link: json["link"],
  );
}
