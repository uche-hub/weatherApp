import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/core/constants/app_color.dart';

class DescriptionText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;
  final Color? color;

  const DescriptionText({
    super.key,
    required this.text,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.color,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.openSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? AppColor.secondaryTextDark, // Fallback to secondaryTextDark
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}