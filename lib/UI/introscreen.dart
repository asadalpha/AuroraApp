import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:my_weather_app/UI/homescree.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';

class LocationController extends GetxController {
  var currentLocation = 'Unknown'.obs;
  var selectedCity = RxString('New York');
  double latitude = 0.0;
  double longitude = 0.0;

  void updateSelectedCity(String city, double lat, double lon) {
    selectedCity.value = city;
    latitude = lat;
    longitude = lon;
  }
}

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final LocationController locationController = Get.put(LocationController());

  @override
  void initState() {
    super.initState();
    _getLocationPermission();
  }

  Future<void> _getLocationPermission() async {
    var status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      _getCurrentLocation();
    } else {
      locationController.currentLocation.value = 'Location permission denied';
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String cityName = _getMajorCityName(placemarks);

      locationController.currentLocation.value = 'City: $cityName';

      locationController.latitude = position.latitude;
      locationController.longitude = position.longitude;
    } catch (e) {
      print('Error: $e');
      locationController.currentLocation.value = 'Error getting location';
    }
  }

  String _getMajorCityName(List<Placemark> placemarks) {
    List<String> majorCities = [
      'New York',
      'London',
      'Tokyo',
      'Paris',
      'Berlin'
    ];

    for (Placemark placemark in placemarks) {
      if (placemark.locality != null &&
          majorCities.contains(placemark.locality)) {
        return placemark.locality!;
      }
    }

    return placemarks.isNotEmpty
        ? placemarks.first.locality ?? 'Unknown City'
        : 'Unknown City';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            SizedBox(
              height: 60.h,
            ),
            Text(
              "Aurora",
              style: GoogleFonts.dancingScript(
                fontSize: 50.sp,
                color: const Color(0xff8DCDFF),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            Center(
              child: Lottie.asset(
                'assets/animation.json',
                repeat: true,
                reverse: false,
                animate: true,
              ),
            ),
            SizedBox(
              height: 32.h,
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: GestureDetector(
                onTap: () {
                  String currentLocation =
                      locationController.currentLocation.value;
                  String location = currentLocation.split('City: ')[0];

                  locationController.updateSelectedCity(
                      location,
                      locationController.latitude,
                      locationController.longitude);
                  Get.to(() => const HomeScreen());
                },
                child: CircleAvatar(
                    backgroundColor: const Color(0xff8DCDFF),
                    radius: 40.h,
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    )),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.only(bottom: 60),
            //   child: SizedBox(
            //     height: 45.h,
            //     width: double.infinity,
            //     child: ElevatedButton(
            //       style: ElevatedButton.styleFrom(
            //           foregroundColor: Colors.white,
            //           backgroundColor: const Color(0xff8DCDFF)),
            //       onPressed: () {
            //         String currentLocation =
            //             locationController.currentLocation.value;
            //         String location = currentLocation.split('City: ')[1];

            //         locationController.updateSelectedCity(
            //             location,
            //             locationController.latitude,
            //             locationController.longitude);
            //         Get.to(const HomeScreen());
            //       },
            //       child: Text(
            //         "Continue",
            //         style: GoogleFonts.roboto(
            //           fontSize: 20.sp,
            //           fontWeight: FontWeight.normal,
            //         ),
            //       ),
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
