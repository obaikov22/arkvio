import 'package:flutter/material.dart';

// ── Light palette ────────────────────────────────────────────────────────────
const kColorBackground     = Color(0xFFF7F5F0);
const kColorSurface        = Color(0xFFFFFFFF);
const kColorSurfaceVariant = Color(0xFFF0EDE6);
const kColorInk            = Color(0xFF1A1A18);
const kColorInkMuted       = Color(0xFF6B6860);
const kColorInkSubtle      = Color(0xFFB0ADA6);
const kColorAccent         = Color(0xFF2D6A4F);
const kColorAccentLight    = Color(0xFFD8EFE4);
const kColorUrgent         = Color(0xFFB85C00);
const kColorUrgentLight    = Color(0xFFFFF0E0);
const kColorDanger         = Color(0xFF9B2335);
const kColorBorder         = Color(0xFFE5E2DC);

// ── Dark palette ─────────────────────────────────────────────────────────────
const kColorBackgroundDark     = Color(0xFF1A1917);
const kColorSurfaceDark        = Color(0xFF232320);
const kColorSurfaceVariantDark = Color(0xFF2C2C28);
const kColorInkDark            = Color(0xFFF0EDE6);
const kColorInkMutedDark       = Color(0xFF9E9B94);
const kColorInkSubtleDark      = Color(0xFF5C5A55);
const kColorAccentDark         = Color(0xFF4A9B72);
const kColorAccentLightDark    = Color(0xFF1A3329);
const kColorUrgentDark         = Color(0xFFD4752A);
const kColorUrgentLightDark    = Color(0xFF2E1E0A);
const kColorDangerDark         = Color(0xFFCF4455);
const kColorBorderDark         = Color(0xFF2E2D29);

// ── Theme-aware accessor ─────────────────────────────────────────────────────
class ArkvioTheme {
  final bool isDark;

  const ArkvioTheme._(this.isDark);

  static ArkvioTheme of(BuildContext context) =>
      ArkvioTheme._(Theme.of(context).brightness == Brightness.dark);

  Color get background    => isDark ? kColorBackgroundDark    : kColorBackground;
  Color get surface       => isDark ? kColorSurfaceDark       : kColorSurface;
  Color get surfaceVar    => isDark ? kColorSurfaceVariantDark : kColorSurfaceVariant;
  Color get ink           => isDark ? kColorInkDark           : kColorInk;
  Color get inkMuted      => isDark ? kColorInkMutedDark      : kColorInkMuted;
  Color get inkSubtle     => isDark ? kColorInkSubtleDark     : kColorInkSubtle;
  Color get accent        => isDark ? kColorAccentDark        : kColorAccent;
  Color get accentLight   => isDark ? kColorAccentLightDark   : kColorAccentLight;
  Color get urgent        => isDark ? kColorUrgentDark        : kColorUrgent;
  Color get urgentLight   => isDark ? kColorUrgentLightDark   : kColorUrgentLight;
  Color get danger        => isDark ? kColorDangerDark        : kColorDanger;
  Color get border        => isDark ? kColorBorderDark        : kColorBorder;
}
