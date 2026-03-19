import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // ── Playfair Display (headings / display) ──────────────────────────────────
  static final TextStyle display =
      GoogleFonts.playfairDisplay(fontSize: 26, fontWeight: FontWeight.w600);

  static final TextStyle appBarTitle =
      GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w600);

  static final TextStyle onboardingTitle =
      GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w600);

  // ── DM Sans (body / UI) ───────────────────────────────────────────────────
  static final TextStyle titleLarge =
      GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600);

  static final TextStyle titleMedium =
      GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500);

  static final TextStyle bodyLarge =
      GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w400);

  static final TextStyle bodyMedium =
      GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w400);

  static final TextStyle caption =
      GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w400);

  static final TextStyle label = GoogleFonts.dmSans(
      fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5);

  static final TextStyle sectionHeader = GoogleFonts.dmSans(
      fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8);

  static final TextStyle button =
      GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500);

  static final TextStyle buttonLarge =
      GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600);

  static final TextStyle tileName =
      GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500);

  static final TextStyle tileSubtitle =
      GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w400);
}
