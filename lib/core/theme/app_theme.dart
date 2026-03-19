import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark  => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: kColorAccent,
      brightness: brightness,
    ).copyWith(
      surface:              isDark ? kColorBackgroundDark     : kColorBackground,
      onSurface:            isDark ? kColorInkDark            : kColorInk,
      surfaceContainerLow:  isDark ? kColorSurfaceDark        : kColorSurface,
      surfaceContainerHighest: isDark ? kColorSurfaceVariantDark : kColorSurfaceVariant,
      primary:              isDark ? kColorAccentDark         : kColorAccent,
      onPrimary:            Colors.white,
      primaryContainer:     isDark ? kColorAccentLightDark    : kColorAccentLight,
      onPrimaryContainer:   isDark ? kColorAccentDark         : kColorAccent,
      secondary:            isDark ? kColorAccentDark         : kColorAccent,
      onSecondary:          Colors.white,
      secondaryContainer:   isDark ? kColorAccentLightDark    : kColorAccentLight,
      error:                isDark ? kColorDangerDark         : kColorDanger,
      outline:              isDark ? kColorBorderDark         : kColorBorder,
      outlineVariant:       isDark ? kColorBorderDark         : kColorBorder,
      onSurfaceVariant:     isDark ? kColorInkMutedDark       : kColorInkMuted,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? kColorBackgroundDark : kColorBackground,

      appBarTheme: AppBarTheme(
        backgroundColor:        isDark ? kColorBackgroundDark : kColorBackground,
        foregroundColor:        isDark ? kColorInkDark        : kColorInk,
        elevation:              0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.appBarTitle.copyWith(
          color: isDark ? kColorInkDark : kColorInk,
        ),
        iconTheme: IconThemeData(color: isDark ? kColorInkMutedDark : kColorInkMuted),
        actionsIconTheme: IconThemeData(color: isDark ? kColorInkMutedDark : kColorInkMuted),
      ),

      cardTheme: CardThemeData(
        color: isDark ? kColorSurfaceDark : kColorSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusMD),
          side: BorderSide(color: isDark ? kColorBorderDark : kColorBorder),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? kColorSurfaceDark : kColorSurface,
        indicatorColor:  isDark ? kColorAccentLightDark : kColorAccentLight,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: isDark ? kColorAccentDark : kColorAccent);
          }
          return IconThemeData(color: isDark ? kColorInkMutedDark : kColorInkMuted);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return AppTextStyles.label.copyWith(
            color: states.contains(WidgetState.selected)
                ? (isDark ? kColorAccentDark : kColorAccent)
                : (isDark ? kColorInkMutedDark : kColorInkMuted),
          );
        }),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: isDark ? kColorAccentDark : kColorAccent,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.buttonLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadiusLG),
          ),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? kColorAccentDark : kColorAccent,
          side: BorderSide(color: isDark ? kColorBorderDark : kColorBorder),
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadiusMD),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark ? kColorInkMutedDark : kColorInkMuted,
          textStyle: AppTextStyles.bodyMedium,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? kColorSurfaceVariantDark : kColorSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusMD),
          borderSide: BorderSide(color: isDark ? kColorBorderDark : kColorBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusMD),
          borderSide: BorderSide(color: isDark ? kColorBorderDark : kColorBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusMD),
          borderSide: BorderSide(
            color: isDark ? kColorAccentDark : kColorAccent,
            width: 2,
          ),
        ),
        hintStyle: AppTextStyles.bodyLarge.copyWith(
          color: isDark ? kColorInkSubtleDark : kColorInkSubtle,
        ),
        labelStyle: AppTextStyles.caption.copyWith(
          color: isDark ? kColorInkMutedDark : kColorInkMuted,
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: isDark ? kColorSurfaceVariantDark : kColorSurfaceVariant,
        selectedColor:   isDark ? kColorAccentLightDark    : kColorAccentLight,
        checkmarkColor:  isDark ? kColorAccentDark         : kColorAccent,
        labelStyle: AppTextStyles.label.copyWith(
          color: isDark ? kColorInkDark : kColorInk,
        ),
        side: BorderSide(color: isDark ? kColorBorderDark : kColorBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusSM),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: isDark ? kColorBorderDark : kColorBorder,
        thickness: 1,
        space: 1,
      ),

      textTheme: GoogleFonts.dmSansTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ).copyWith(
        displayLarge: AppTextStyles.display.copyWith(
          color: isDark ? kColorInkDark : kColorInk,
        ),
        titleLarge: AppTextStyles.titleLarge.copyWith(
          color: isDark ? kColorInkDark : kColorInk,
        ),
        titleMedium: AppTextStyles.titleMedium.copyWith(
          color: isDark ? kColorInkDark : kColorInk,
        ),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(
          color: isDark ? kColorInkDark : kColorInk,
        ),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(
          color: isDark ? kColorInkDark : kColorInk,
        ),
        labelSmall: AppTextStyles.label.copyWith(
          color: isDark ? kColorInkMutedDark : kColorInkMuted,
        ),
      ),
    );
  }
}
