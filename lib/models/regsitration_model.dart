class RegistrationModel {
  bool success;
  String message;
  RegistrationDetails data;

  RegistrationModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory RegistrationModel.fromJson(Map<String, dynamic> json) =>
      RegistrationModel(
        success: json["success"],
        message: json["message"],
        data: RegistrationDetails.fromJson(json["data"]),
      );
}

class RegistrationDetails {
  int id;
  String deviceId;
  String appVersion;
  String status;

  RegistrationDetails({
    required this.id,
    required this.deviceId,
    required this.appVersion,
    required this.status,
  });

  factory RegistrationDetails.fromJson(Map<String, dynamic> json) =>
      RegistrationDetails(
        id: json["id"],
        deviceId: json["deviceId"],
        appVersion: json["appVersion"],
        status: json["status"],
      );
}
