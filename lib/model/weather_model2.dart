class WeatherData2 {
  final double latitude;
  final double longitude;
  final String timezone;
  final List<HourlyData2> hourly;

  WeatherData2({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.hourly,
  });

  factory WeatherData2.fromJson(Map<String, dynamic> json) {
    var hourlyList = json['hourly']['time'] as List;
    List<HourlyData2> hourlyDataList = hourlyList.map((i) {
      return HourlyData2.fromJson(
          i, json['hourly']['temperature_2m'][hourlyList.indexOf(i)]);
    }).toList();

    return WeatherData2(
      latitude: json['latitude'],
      longitude: json['longitude'],
      timezone: json['timezone'],
      hourly: hourlyDataList,
    );
  }
}

class HourlyData2 {
  final DateTime time;
  final double temperature;

  HourlyData2({
    required this.time,
    required this.temperature,
  });

  factory HourlyData2.fromJson(String time, double temperature) {
    return HourlyData2(
      time: DateTime.parse(time),
      temperature: temperature,
    );
  }
}
