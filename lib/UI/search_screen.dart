import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:my_weather_app/secrets.dart';

class CityList extends StatefulWidget {
  const CityList({Key? key}) : super(key: key);

  @override
  State<CityList> createState() => _CityListState();
}

class _CityListState extends State<CityList> {
  List<String> imageList = [
    "assets/tower.jpg",
    "assets/image4.jpg",
    "assets/image5.jpg",
    "assets/image6.jpg",
  ];

  List<String> cities = ["New York", "London", "Paris", "Delhi"];
  late List<Future<Map<String, dynamic>>> cityWeatherList;

  @override
  void initState() {
    super.initState();
    // Initialize the list of futures to fetch weather for each city
    cityWeatherList = cities.map((city) => getCurrentWeather(city)).toList();
  }

  Future<Map<String, dynamic>> getCurrentWeather(String cityName) async {
    try {
      final res = await http.get(Uri.parse(
          "http://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$APIKey"));

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Locations",
                style: GoogleFonts.roboto(
                  fontSize: 16.sp,
                  color: const Color.fromARGB(255, 109, 106, 106),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              // Display current weather for the first city in the list
              FutureBuilder(
                future: getCurrentWeather(cities[0]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator.adaptive());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }
                  final data = snapshot.data!;
                  final currentCity = data['city']['name'];
                  final currentTemp =
                      (data['list'][0]['main']['temp'] - 273.15).round();

                  return Container(
                    height: 100.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: const DecorationImage(
                        fit: BoxFit.fitWidth,
                        image: AssetImage("assets/image1.jpg"),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20, bottom: 10),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "$currentCity",
                                    style: GoogleFonts.roboto(
                                      fontSize: 18.sp,
                                      color: const Color.fromARGB(
                                          255, 235, 233, 233),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Text(
                                  " $currentTemp°",
                                  style: GoogleFonts.roboto(
                                    fontSize: 26.sp,
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(
                height: 20.h,
              ),
              Text(
                "Recommended",
                style: GoogleFonts.roboto(
                  fontSize: 16.sp,
                  color: const Color.fromARGB(255, 109, 106, 106),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              // Display recommended cities with their respective weather
              Expanded(
                child: ListView.builder(
                  itemCount: imageList.length,
                  itemBuilder: (context, index) {
                    final cityWeather = cityWeatherList[index];

                    return FutureBuilder(
                      future: cityWeather,
                      builder: (context, citySnapshot) {
                        if (citySnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator.adaptive();
                        }
                        if (citySnapshot.hasError) {
                          return Text(citySnapshot.error.toString());
                        }
                        final cityData = citySnapshot.data!;
                        final cityName = cityData['city']['name'];
                        final cityTemp =
                            (cityData['list'][0]['main']['temp'] - 273.15)
                                .round();

                        return Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Container(
                            height: 100.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                fit: BoxFit.fitWidth,
                                image: AssetImage(imageList[index]),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, bottom: 10),
                                  child: Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cityName.isNotEmpty ? cityName : "",
                                            style: GoogleFonts.roboto(
                                              fontSize: 18.sp,
                                              color: const Color.fromARGB(
                                                  255, 235, 233, 233),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 20),
                                        child: Text(
                                          " $cityTemp°",
                                          style: GoogleFonts.roboto(
                                            fontSize: 26.sp,
                                            color: const Color.fromARGB(
                                                255, 255, 255, 255),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
