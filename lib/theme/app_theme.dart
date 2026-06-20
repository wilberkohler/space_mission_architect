import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────

class AppColors {
  // Backgrounds
  static const Color bg = Color(0xFF050B16);
  static const Color bgDeep = Color(0xFF030810);
  static const Color panel = Color(0xFF0C1928);
  static const Color panelLight = Color(0xFF112033);
  static const Color panelMid = Color(0xFF091422);

  // Borders
  static const Color panelBorder = Color(0xFF18304A);
  static const Color panelBorderSubtle = Color(0xFF0E2035);

  // Accent / Highlights
  static const Color accent = Color(0xFF3CD6FF);
  static const Color accentGlow = Color(0x2A3CD6FF);
  static const Color accentDim = Color(0xFF1A8CA8);

  // Semantic colours
  static const Color green = Color(0xFF00E676);
  static const Color greenGlow = Color(0x2A00E676);
  static const Color greenDim = Color(0xFF00A854);
  static const Color yellow = Color(0xFFFFD740);
  static const Color yellowGlow = Color(0x2AFFD740);
  static const Color orange = Color(0xFFFF9100);
  static const Color orangeGlow = Color(0x2AFF9100);
  static const Color red = Color(0xFFFF5252);
  static const Color redGlow = Color(0x2AFF5252);
  static const Color purple = Color(0xFFAD6DFF);
  static const Color purpleGlow = Color(0x2AAD6DFF);

  // Text
  static const Color textPrimary = Color(0xFFE8F0FF);
  static const Color textSecondary = Color(0xFF7A9CC0);
  static const Color textMuted = Color(0xFF3D6080);

  // Mission-status aliases (kept for backwards compat)
  static const Color available = Color(0xFF3CD6FF);
  static const Color success = Color(0xFF00E676);
  static const Color locked = Color(0xFF3D6080);
  static const Color inProgress = Color(0xFFFF9100);
}

// ─── Spacing tokens ───────────────────────────────────────────────────────────

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

// ─── Radius tokens ────────────────────────────────────────────────────────────

class AppRadius {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 22;
  static const double circle = 999;
}

// ─── Shadow helpers ───────────────────────────────────────────────────────────

class AppShadows {
  static List<BoxShadow> card({Color color = AppColors.accent, double opacity = 0.05}) => <BoxShadow>[
        BoxShadow(color: color.withOpacity(opacity), blurRadius: 16, spreadRadius: 0),
      ];

  static List<BoxShadow> glow(Color color, {double opacity = 0.35, double blur = 24}) => <BoxShadow>[
        BoxShadow(color: color.withOpacity(opacity * 0.6), blurRadius: blur * 0.5, spreadRadius: 0),
        BoxShadow(color: color.withOpacity(opacity), blurRadius: blur, spreadRadius: 2),
      ];

  static List<BoxShadow> criticalGlow = <BoxShadow>[
    BoxShadow(color: AppColors.red.withOpacity(0.25), blurRadius: 16, spreadRadius: 1),
    BoxShadow(color: AppColors.red.withOpacity(0.12), blurRadius: 32, spreadRadius: 4),
  ];
}

// ─── Decoration helpers ───────────────────────────────────────────────────────

class AppDecorations {
  static BoxDecoration panel({Color? accent, double radius = AppRadius.lg}) {
    final Color border = (accent ?? AppColors.panelBorder).withOpacity(accent != null ? 0.3 : 1.0);
    return BoxDecoration(
      color: AppColors.panel,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border, width: 1),
      boxShadow: accent != null ? AppShadows.card(color: accent) : null,
    );
  }

  static BoxDecoration glassPanel({Color? accent, double radius = AppRadius.lg}) {
    final Color a = accent ?? AppColors.accent;
    return BoxDecoration(
      color: AppColors.panel,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: a.withOpacity(0.3), width: 1.5),
      boxShadow: AppShadows.card(color: a, opacity: 0.06),
    );
  }

  static BoxDecoration statusBadge(Color color) => BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
      );

  static BoxDecoration chip(Color color) => BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.circle),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      );
}

// ─── ThemeData ────────────────────────────────────────────────────────────────

class AppTheme {
  static ThemeData get darkControlCenterTheme {
    final ThemeData base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.yellow,
        tertiary: AppColors.purple,
        error: AppColors.red,
        surface: AppColors.panel,
        onSurface: AppColors.textPrimary,
        outline: AppColors.panelBorder,
      ),

      // ── App bar ──────────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: AppColors.textSecondary),
      ),

      // ── Cards ─────────────────────────────────────────────────────────────
      cardTheme: const CardThemeData(
        color: AppColors.panel,
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
          side: BorderSide(color: AppColors.panelBorder, width: 1),
        ),
      ),

      // ── Elevated button ───────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent.withOpacity(0.15),
          foregroundColor: AppColors.accent,
          side: const BorderSide(color: AppColors.accent, width: 1),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.8, fontSize: 13),
        ),
      ),

      // ── Outlined button ───────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: const BorderSide(color: AppColors.panelBorder),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),

      // ── Text button ───────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),

      // ── Tabs ──────────────────────────────────────────────────────────────
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.accent,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.accent,
        dividerColor: AppColors.panelBorder,
        labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 0.5),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
      ),

      // ── Text ──────────────────────────────────────────────────────────────
      textTheme: base.textTheme.copyWith(
        displayLarge: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        displayMedium: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        headlineLarge: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 26, letterSpacing: 0.3),
        headlineMedium: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 22),
        titleLarge: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18, letterSpacing: 0.4),
        titleMedium: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15),
        titleSmall: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13),
        bodyLarge: const TextStyle(color: AppColors.textPrimary, fontSize: 15, height: 1.5),
        bodyMedium: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
        bodySmall: const TextStyle(color: AppColors.textMuted, fontSize: 11, height: 1.4),
        labelLarge: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 0.8),
        labelMedium: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 11, letterSpacing: 0.5),
        labelSmall: const TextStyle(color: AppColors.textMuted, fontSize: 10, letterSpacing: 0.5),
      ),

      // ── Slider ────────────────────────────────────────────────────────────
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.accent,
        inactiveTrackColor: AppColors.panelBorder,
        thumbColor: AppColors.accent,
        overlayColor: AppColors.accentGlow,
        trackHeight: 3,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(color: AppColors.panelBorder, thickness: 1, space: 1),

      // ── Chip ──────────────────────────────────────────────────────────────
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.panelLight,
        labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        side: BorderSide(color: AppColors.panelBorder),
        shape: StadiumBorder(),
      ),

      // ── Bottom nav ────────────────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.panel,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textMuted,
        selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5),
        unselectedLabelStyle: TextStyle(fontSize: 10),
        elevation: 0,
      ),

      // ── Input decoration ──────────────────────────────────────────────────
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.panelLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
          borderSide: BorderSide(color: AppColors.panelBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
          borderSide: BorderSide(color: AppColors.panelBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
          borderSide: BorderSide(color: AppColors.accent, width: 1.5),
        ),
        labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      ),

      // ── Progress indicator ────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
        linearTrackColor: AppColors.panelBorder,
        circularTrackColor: AppColors.panelBorder,
      ),

      // ── Icon ──────────────────────────────────────────────────────────────
      iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 20),
    );
  }
}
