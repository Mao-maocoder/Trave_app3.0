import 'tourist_spot.dart';

class ItineraryItem {
  final TouristSpot spot;
  final DateTime startTime;
  final int durationMinutes;
  final String? notes;

  ItineraryItem({
    required this.spot,
    required this.startTime,
    required this.durationMinutes,
    this.notes,
  });

  DateTime get endTime => startTime.add(Duration(minutes: durationMinutes));

  String get formattedStartTime {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }

  String get formattedEndTime {
    return '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  }

  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0) {
      return '${hours}小时${minutes > 0 ? '${minutes}分钟' : ''}';
    } else {
      return '${minutes}分钟';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'spot': spot.toJson(),
      'startTime': startTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'notes': notes,
    };
  }

  factory ItineraryItem.fromJson(Map<String, dynamic> json) {
    return ItineraryItem(
      spot: TouristSpot.fromJson(json['spot']),
      startTime: DateTime.parse(json['startTime']),
      durationMinutes: json['durationMinutes'],
      notes: json['notes'],
    );
  }
} 