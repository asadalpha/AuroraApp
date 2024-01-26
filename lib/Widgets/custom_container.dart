import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomContainer extends StatelessWidget {
  const CustomContainer(
      {super.key,
      required this.customIcon,
      required this.customText1,
      required this.customText2});
  final String customText1;
  final String customText2;
  final IconData customIcon;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(
        customText1,
        style: GoogleFonts.roboto(
          fontSize: 14.sp,
          color: const Color.fromARGB(255, 174, 172, 173),
          fontWeight: FontWeight.bold,
        ),
      ),
      Icon(
        customIcon,
        size: 36,
        color: const Color.fromARGB(255, 174, 172, 172),
      ),
      Text(
        customText2,
        style: GoogleFonts.roboto(
          fontSize: 16.sp,
          color: const Color.fromARGB(255, 174, 172, 173),
          fontWeight: FontWeight.bold,
        ),
      ),
    ]);
  }
}
