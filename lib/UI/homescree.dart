import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:my_weather_app/UI/introscreen.dart';
import 'package:my_weather_app/UI/search_screen.dart';
import 'package:my_weather_app/Widgets/custom_container.dart';
import 'package:my_weather_app/secrets.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> weather;
  final locationController = Get.find<LocationController>();

  Future<Map<String, dynamic>> getCurrentWeather(String cityName) async {
    //final selectedCity = Get.find<LocationController>().selectedCity.value;
    final latitude = locationController.latitude;
    final longitude = locationController.longitude;
    //final cityName = locationController.currentLocation.value;

    try {
      final res = await http.get(Uri.parse(
          "https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&cnt=5&appid=$APIKey"));

      final data = jsonDecode(res.body);
      if (data['cod'] != "200") {
        throw "An Unexpected error Occurred";
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();

    final selectedCity = Get.find<LocationController>().selectedCity.value;
    weather = getCurrentWeather(selectedCity);
  }

  final List<Color> bgColor = [
    const Color(0xffEFC7B8),
    const Color(0xff86B6F6),
    const Color(0xffAC87C5),
  ];

  Color getColor(String currentSky) {
    switch (currentSky.toLowerCase()) {
      case 'clear':
        return const Color(0xffEFC7B8);
      case 'rain':
        return const Color(0xffAC87C5);
      case 'clouds':
        return const Color(0xff8DCDFF);

      default:
        return const Color(0xffEFC7B8);
    }
  }

  IconData getCustomIcon(String currentSky) {
    switch (currentSky.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud_outlined;
      case 'rain':
        return Icons.water_drop_outlined;
      default:
        return Icons.wb_sunny; // Default icon
    }
  }

  String getImageAssetForSky(String currentSky) {
    switch (currentSky.toLowerCase()) {
      case 'clear':
        return "image2.png";
      case 'clouds':
        return "assets/image_cloudy.png";
      case 'rain':
        return "image_rainy.png";

      default:
        return "image2.png";
    }
  }

  Future<void> _refresh() async {
    try {
      // Fetch new weather data
      final selectedCity = locationController.selectedCity.value;
      final newWeather = await getCurrentWeather(selectedCity);

      // Update the UI with the new data
      setState(() {
        weather = Future.value(newWeather);
      });
    } catch (e) {
      // Handle errors if necessary
      print("Error refreshing data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Colors.white,
        onPressed: () {
          Get.to(() => const CityList());
        },
        child: const Icon(
          Icons.arrow_forward_ios,
          color: Color.fromARGB(255, 0, 0, 0),
        ),
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          //for error handling
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final data = snapshot.data!;
          final currentSky = data['list'][0]['weather'][0]['main'];
          final currentTemp = data['list'][0]['main']['temp'];
          final currentPressure = data['list'][0]['main']['pressure'];
          final currentHumidity = data['list'][0]['main']['humidity'];
          final currentWindSpeed = data['list'][0]['wind']['speed'];

          final temp = (currentTemp - 273.15).round();
          final city = data['city']['name'];
          return RefreshIndicator(
            onRefresh: _refresh,
            child: Column(
              children: [
                Container(
                  height: 440.h,
                  width: double.infinity,
                  color: getColor(currentSky),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Text(
                            "$currentSky",
                            style: GoogleFonts.roboto(
                              fontSize: 22.sp,
                              color: const Color.fromARGB(255, 241, 242, 244),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          "$city",
                          style: GoogleFonts.roboto(
                            fontSize: 20.sp,
                            color: const Color.fromARGB(255, 241, 242, 244),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(
                          height: 14.h,
                        ),
                        Text(
                          "$temp" "°",
                          style: GoogleFonts.roboto(
                            fontSize: 68.sp,
                            color: const Color.fromARGB(255, 241, 242, 244),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(
                          height: 14.h,
                        ),
                        Container(
                          height: 140.h,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(
                                      getImageAssetForSky(currentSky)))),
                        )
                      ]),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40, top: 36),
                    child: Text(
                      "$city".toUpperCase(),
                      style: GoogleFonts.roboto(
                        fontSize: 22.sp,
                        color: getColor(currentSky),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                //AdditionalInfoBox(icon: (Icons.cloud), txt1: "Hello", txt2: "123")
                // more weather details in row
                SizedBox(
                  height: 40.h,
                ),
                Container(
                  alignment: Alignment.center,
                  height: 120,
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        final temp1 = (data['list'][index + 1]['main']['temp']);
                        final hourlyTemp = (temp1 - 273.15).round();
                        final time =
                            DateTime.parse(data['list'][index + 1]['dt_txt']);
                        final formattedTime = DateFormat('j').format(time);
                        return Padding(
                          padding: const EdgeInsets.only(left: 12, right: 12),
                          child: CustomContainer(
                            customText1: "$formattedTime°",
                            customText2: "$hourlyTemp",
                            customIcon: getCustomIcon(currentSky),
                          ),
                        );
                      }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
