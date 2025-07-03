import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/core/constants/app_color.dart';

/// A reusable widget for displaying header text (e.g., titles) in the weather app.
class HeaderText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;

  const HeaderText({
    super.key,
    required this.text,
    this.fontSize = 24.0,
    this.fontWeight = FontWeight.bold,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.roboto(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: Theme.of(context).textTheme.titleLarge?.color ?? AppColor.primaryTextLight,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}