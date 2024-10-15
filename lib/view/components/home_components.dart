// Top bar widget
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:superior_weather/model/weather_model2.dart';
import 'package:superior_weather/resources/colors.dart';
import 'package:superior_weather/view_model/city_suggestion_model.dart';
import 'package:superior_weather/view_model/services/audio_services.dart';
import 'package:superior_weather/view_model/weather_view_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
String _city = '';

Widget buildTopBar(double height, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(top: 15),
    child: SizedBox(
      width: double.infinity,
      height: height * 0.1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ClipRect(
            child: Align(
              alignment: Alignment.center,
              widthFactor: 0.6, // Adjust width factor to crop sides
              heightFactor: 0.6, // Adjust height factor to crop top and bottom
              child: Image.asset(
                'assets/images/splash_logo.png',
                width: MediaQuery.of(context).size.width * 0.8,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () => _openSearchDrawer(context),
          ),
        ],
      ),
    ),
  );
}

// Watch Live and Listen Live section widget
Widget buildLiveWatchAndListenRow(
    BuildContext context, WebViewController controller) {
  final audioProvider = Provider.of<AudioProvider>(context);
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      const Text('Watch Live', style: TextStyle(color: Colors.white)),
      const Row(
        children: [
          Icon(FontAwesomeIcons.facebook, color: Color(0xff1877F2), size: 18),
          SizedBox(width: 5),
          Icon(FontAwesomeIcons.instagram, color: Color(0xffFCAF45), size: 18),
          SizedBox(width: 5),
          Icon(FontAwesomeIcons.linkedin, color: Color(0xff0077B5), size: 18),
        ],
      ),
      const Text('|',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
      IconButton(
        icon: Icon(
          audioProvider.playerState == PlayerState.playing
              ? Icons.pause
              : Icons.play_arrow,
          color: Colors.white,
        ),
        onPressed: () async {
          try {
            if (audioProvider.playerState == PlayerState.playing) {
              await audioProvider.pause();
            } else {
              await audioProvider.play();
            }
          } catch (e) {
            // Handle exceptions (show a snackbar, log the error, etc.)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${e.toString()}'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      ),
      const Text('Listen Live', style: TextStyle(color: Colors.white)),
      IconButton(
        icon: const Icon(Icons.launch, color: Colors.white),
        onPressed: () {
          _showWebViewDialog(context, controller);
        },
      ),
    ],
  );
}

// Weather Info with Shimmer effect for loading
Widget buildWeatherInfoWithShimmer(WeatherProvider weatherProvider) {
  final weatherData = weatherProvider.weather;

  return Center(
    child: Column(
      children: [
        weatherData != null
            ? Text(
                weatherData.name!,
                style: GoogleFonts.lato(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
            : buildShimmerPlaceholder(width: 150, height: 34),
        const SizedBox(height: 8),
        weatherData != null
            ? Text(
                '${weatherData.main!.temp}°F', // Current temperature
                style: GoogleFonts.lato(
                  fontSize: 70,
                  color: Colors.white,
                ),
              )
            : buildShimmerPlaceholder(width: 100, height: 80),
        const SizedBox(height: 8),
        weatherData != null
            ? Text(
                'Feels like ${weatherData.main!.feelsLike}°F',
                style: GoogleFonts.lato(
                  fontSize: 20,
                  color: Colors.white70,
                ),
              )
            : buildShimmerPlaceholder(width: 120, height: 20),
      ],
    ),
  );
}

// Shimmer Placeholder Widget
Widget buildShimmerPlaceholder(
    {required double width, required double height}) {
  return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.white,
      child: Text(
        '000',
        style: TextStyle(fontSize: height, color: Colors.black38),
      ));
}

Widget buildHourlyForecast(WeatherProvider weatherProvider) {
  final weather2Data = weatherProvider.weather2;
  final today = DateTime.now();

  // Split the hourly data into today's data and the remaining days
  final todayForecast = weather2Data!.hourly
      .where((hourlyData) => isSameDay(hourlyData.time, today))
      .toList();
  final futureForecast = weather2Data.hourly
      .where((hourlyData) => !isSameDay(hourlyData.time, today))
      .toList();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildDaySection(todayForecast, weatherProvider),
      const SizedBox(height: 20),
      _buildExpandableForecastSection(futureForecast, weatherProvider),
    ],
  );
}

Widget _buildDaySection(
    List<HourlyData2> hourlyData, WeatherProvider provider) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    decoration: BoxDecoration(
      color: Colors.black38,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        Text(
          'Hourly Forecast',
          style: GoogleFonts.lato(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: hourlyData.length,
            itemBuilder: (context, index) {
              final hourly = hourlyData[index];
              return _buildHourlyForecastCard(
                  hourly.time,
                  '${hourly.temperature}°F',
                  provider.getIconForTemperatureAndTime(
                      hourly.temperature, hourly.time));
            },
          ),
        ),
      ],
    ),
  );
}

Widget _buildDaySection2(
    List<HourlyData2> hourlyData, WeatherProvider provider, String date) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    decoration: BoxDecoration(
      color: Colors.black38,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        Text(
          date,
          style: GoogleFonts.lato(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: hourlyData.length,
            itemBuilder: (context, index) {
              final hourly = hourlyData[index];
              return _buildHourlyForecastCard(
                  hourly.time,
                  '${hourly.temperature}°F',
                  provider.getIconForTemperatureAndTime(
                      hourly.temperature, hourly.time));
            },
          ),
        ),
      ],
    ),
  );
}

Widget _buildExpandableForecastSection(
    List<HourlyData2> futureForecast, WeatherProvider provider) {
  // Group hourly forecast by date
  Map<String, List<HourlyData2>> groupedByDate = {};

  for (var hourly in futureForecast) {
    String formattedDate = DateFormat('d MMM, yyyy')
        .format(hourly.time); // Format date as '9 Oct, 2023'
    if (!groupedByDate.containsKey(formattedDate)) {
      groupedByDate[formattedDate] = [];
    }
    groupedByDate[formattedDate]!
        .add(hourly); // Add hourly data to the corresponding date group
  }

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.black38,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            provider.toggleExpanded(); // Toggle the expanded state
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '14-Day Forecast',
                style: GoogleFonts.lato(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                provider.isExpanded
                    ? FontAwesomeIcons.chevronUp
                    : FontAwesomeIcons.chevronDown,
                color: Colors.white,
              ),
            ],
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          firstCurve: Curves.linearToEaseOut,
          secondChild: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection:
                Axis.vertical, // Ensure vertical scrolling for different dates
            itemCount: groupedByDate.length, // Number of unique dates
            itemBuilder: (context, index) {
              String dateKey = groupedByDate.keys.elementAt(index);
              List<HourlyData2> hourlyDataForDate = groupedByDate[dateKey]!;

              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 8), // Add space between cards
                child: _buildDaySection2(hourlyDataForDate, provider,
                    dateKey), // Pass the dateKey to display
              );
            },
          ),
          crossFadeState: provider.isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    ),
  );
}

Widget _buildHourlyForecastCard(
    DateTime time, String temperature, IconData icon) {
  return Card(
    color: Colors.black26,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 5),
          Text(
            DateFormat.jm().format(time),
            style: GoogleFonts.lato(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            temperature,
            style: GoogleFonts.lato(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}

bool isSameDay(DateTime day1, DateTime day2) {
  return day1.year == day2.year &&
      day1.month == day2.month &&
      day1.day == day2.day;
}

// Live Radar section widget
Widget buildLiveRadar(String hintLine, String image, BuildContext context,
    {required VoidCallback onTap}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            image,
            fit: BoxFit.fill,
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              hintLine,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// Section title widget
Widget buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(left: 10.0, bottom: 8.0),
    child: Text(
      title,
      style: GoogleFonts.lato(
        fontSize: 22,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

void _openSearchDrawer(BuildContext context) {
  TextEditingController lat = TextEditingController();
  TextEditingController long = TextEditingController();
  showModalBottomSheet(
    backgroundColor: AppColors.primaryColor2,
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16.0,
          right: 16.0,
          top: 16.0,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(color: Colors.white),
                    labelText: 'Enter city name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onChanged: (value) {
                    // Fetch suggestions as user types
                    Provider.of<CitySuggestionProvider>(context, listen: false)
                        .fetchCitySuggestions(value);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Flexible(
                      child: TextFormField(
                        controller: lat,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelStyle: const TextStyle(color: Colors.white),
                          labelText: 'lat',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: TextFormField(
                        controller: long,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelStyle: const TextStyle(color: Colors.white),
                          labelText: 'lng',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Lat/lng should be accurate',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Consumer<CitySuggestionProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const CircularProgressIndicator();
                    }

                    if (provider.citySuggestions.isEmpty) {
                      return const Text(
                        'No suggestions',
                        style: TextStyle(color: Colors.white),
                      );
                    }

                    return SizedBox(
                      height: 150,
                      child: ListView.builder(
                        itemCount: provider.citySuggestions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              provider.citySuggestions[index],
                              style: const TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              _city = provider.citySuggestions[index];
                              Provider.of<WeatherProvider>(context,
                                      listen: false)
                                  .fetchWeatherData(_city);
                              Provider.of<CitySuggestionProvider>(context,
                                      listen: false)
                                  .saveCityToLocal(
                                      _city); // Save to local storage
                              Provider.of<CitySuggestionProvider>(context,
                                      listen: false)
                                  .clearSuggestions();
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      //print('Button Pressed');
                      if (lat.text.isNotEmpty && long.text.isNotEmpty) {
                        double? latitude = double.tryParse(lat.text);
                        double? longitude = double.tryParse(long.text);

                        String? city =
                            await _getCityFromLatLng(latitude!, longitude!);
                        // print('City = $city');
                        Provider.of<WeatherProvider>(context, listen: false)
                            .fetchWeatherData(city!);
                        Provider.of<CitySuggestionProvider>(context,
                                listen: false)
                            .saveCityToLocal(city); // Save to local storage
                        Provider.of<CitySuggestionProvider>(context,
                                listen: false)
                            .clearSuggestions();
                        Navigator.pop(context);
                      } else {
                        Provider.of<WeatherProvider>(context, listen: false)
                            .fetchWeatherData(_city);
                        Provider.of<CitySuggestionProvider>(context,
                                listen: false)
                            .saveCityToLocal(_city); // Save to local storage
                        Provider.of<CitySuggestionProvider>(context,
                                listen: false)
                            .clearSuggestions();
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: const Text('Search'),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// Method to convert lat/lng to city name using reverse geocoding
Future<String?> _getCityFromLatLng(double lat, double lng) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
    if (placemarks.isNotEmpty) {
      return placemarks.first.locality; // Return the locality (city)
    }
  } catch (e) {
    Fluttertoast.showToast(msg: 'Error converting lat/lng to city');
  }
  return null;
}

void _showWebViewDialog(
    BuildContext context, WebViewController webViewController) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Radio Player'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400, // Adjust height as needed
          child: WebViewWidget(controller: webViewController),
        ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
