class TvDisplayResponse {
  final bool? status;
  final String? message;
  final TvDisplayDetails? data;

  TvDisplayResponse({this.status, this.message, this.data});

  factory TvDisplayResponse.fromJson(Map<String, dynamic> json) =>
      TvDisplayResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : TvDisplayDetails.fromJson(json["data"]),
      );
}

class TvDisplayDetails {
  final List<Room>? currentRooms;
  final List<Room>? upcomingRooms;
  final Statistics? statistics;

  TvDisplayDetails({this.currentRooms, this.upcomingRooms, this.statistics});

  factory TvDisplayDetails.fromJson(
    Map<String, dynamic> json,
  ) => TvDisplayDetails(
    currentRooms: json["currentRooms"] == null
        ? []
        : List<Room>.from(json["currentRooms"]!.map((x) => Room.fromJson(x))),
    upcomingRooms: json["upcomingRooms"] == null
        ? []
        : List<Room>.from(json["upcomingRooms"]!.map((x) => Room.fromJson(x))),
    statistics: json["statistics"] == null
        ? null
        : Statistics.fromJson(json["statistics"]),
  );
}

class Room {
  final String? id;
  final String? name;
  final String? location;
  final int? capacity;
  final Meeting? currentMeeting;
  final bool? booked;

  Room({
    this.id,
    this.name,
    this.location,
    this.capacity,
    this.currentMeeting,
    this.booked,
  });

  factory Room.fromJson(Map<String, dynamic> json) => Room(
    id: json["id"],
    name: json["name"],
    location: json["location"],
    capacity: json["capacity"],
    currentMeeting: json["currentMeeting"] == null
        ? null
        : Meeting.fromMap(json["currentMeeting"]),
    booked: json["booked"],
  );
}

class Meeting {
  final String organizer;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final int attendees;

  Meeting({
    required this.organizer,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.attendees,
  });

  // New formatted time getters
  String get startTimeFormatted {
    return "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";
  }

  String get endTimeFormatted {
    return "${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}";
  }

  // ⏳ Computed field — not from server
  int get remainingSeconds {
    final now = DateTime.now();
    final diff = endTime.difference(now);
    final secs = diff.inSeconds;
    return secs > 0 ? secs : 0;
  }

  int get remainingMinutes {
    return (remainingSeconds / 60).ceil();
  }

  factory Meeting.fromMap(Map<String, dynamic> map) {
    return Meeting(
      organizer: map['organizer'] as String,
      title: map['title'] as String,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: DateTime.parse(map['endTime'] as String),
      attendees: map['attendees'] as int,
    );
  }
}

class Statistics {
  final int? totalRooms;
  final int? busyRooms;
  final int? freeRooms;

  Statistics({this.totalRooms, this.busyRooms, this.freeRooms});

  factory Statistics.fromJson(Map<String, dynamic> json) => Statistics(
    totalRooms: json["totalRooms"],
    busyRooms: json["busyRooms"],
    freeRooms: json["freeRooms"],
  );

  Map<String, dynamic> toJson() => {
    "totalRooms": totalRooms,
    "busyRooms": busyRooms,
    "freeRooms": freeRooms,
  };
}
