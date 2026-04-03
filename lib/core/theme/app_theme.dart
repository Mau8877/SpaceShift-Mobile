import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

abstract final class AppColors {
  // ── Light ──────────────────────────────────────────────────────────────
  static const lBackground = Color(0xFFFFFFFF);
  static const lForeground = Color(0xFF1A1A23);
  static const lCard = Color(0xFFFFFFFF);
  static const lCardForeground = Color(0xFF1A1A23);
  static const lPopover = Color(0xFFFFFFFF);
  static const lPopoverForeground = Color(0xFF1A1A23);
  static const lPrimary = Color(0xFF2F6EB5);
  static const lPrimaryForeground = Color(0xFFF0F8FF);
  static const lSecondary = Color(0xFFF4F4F6);
  static const lSecondaryForeground = Color(0xFF2F2F3A);
  static const lMuted = Color(0xFFF4F4F6);
  static const lMutedForeground = Color(0xFF6B6B80);
  static const lAccent = Color(0xFFF4F4F6);
  static const lAccentForeground = Color(0xFF2F2F3A);
  static const lDestructive = Color(0xFFE0350D);
  static const lBorder = Color(0xFFE8E8EC);
  static const lInput = Color(0xFFE8E8EC);
  static const lRing = Color(0xFFA8A8B8);

  // Chart – light (mismo en ambos temas según el CSS)
  static const chart1 = Color(0xFF8DCDE8); // oklch(0.828 0.111 230.318)
  static const chart2 = Color(0xFF4490D4); // oklch(0.685 0.169 237.323)
  static const chart3 = Color(0xFF3070B8); // oklch(0.588 0.158 241.966)
  static const chart4 = Color(0xFF2F6EB5); // oklch(0.5 0.134 242.749)
  static const chart5 = Color(0xFF2A5A99); // oklch(0.443 0.11 240.79)

  // ── Dark ───────────────────────────────────────────────────────────────
  static const dBackground = Color(0xFF1A1A23);
  static const dForeground = Color(0xFFFAFAFA);
  static const dCard = Color(0xFF2F2F3A);
  static const dCardForeground = Color(0xFFFAFAFA);
  static const dPopover = Color(0xFF2F2F3A);
  static const dPopoverForeground = Color(0xFFFAFAFA);
  static const dPrimary = Color(0xFF2A5A99);
  static const dPrimaryForeground = Color(0xFFF0F8FF);
  static const dSecondary = Color(0xFF3C3C4A);
  static const dSecondaryForeground = Color(0xFFFAFAFA);
  static const dMuted = Color(0xFF3C3C4A);
  static const dMutedForeground = Color(0xFFA8A8B8);
  static const dAccent = Color(0xFF3C3C4A);
  static const dAccentForeground = Color(0xFFFAFAFA);
  static const dDestructive = Color(0xFFF06040);
  static const dBorder = Color(0x1AFFFFFF);
  static const dInput = Color(0x26FFFFFF);
  static const dRing = Color(0xFF6B6B80);
}

abstract final class AppTheme {
  // ── Radio de bordes (--radius: 0.625rem ≈ 10px) ──────────────────────
  static const _borderRadius = BorderRadius.all(Radius.circular(10));

  // ══════════════════════════════════════════════════════════════════════
  //  LIGHT
  // ══════════════════════════════════════════════════════════════════════
  static final ShadThemeData light = ShadThemeData(
    brightness: Brightness.light,
    colorScheme: const ShadColorScheme(
      background: AppColors.lBackground,
      foreground: AppColors.lForeground,
      card: AppColors.lCard,
      cardForeground: AppColors.lCardForeground,
      popover: AppColors.lPopover,
      popoverForeground: AppColors.lPopoverForeground,
      primary: AppColors.lPrimary,
      primaryForeground: AppColors.lPrimaryForeground,
      secondary: AppColors.lSecondary,
      secondaryForeground: AppColors.lSecondaryForeground,
      muted: AppColors.lMuted,
      mutedForeground: AppColors.lMutedForeground,
      accent: AppColors.lAccent,
      accentForeground: AppColors.lAccentForeground,
      destructive: AppColors.lDestructive,
      destructiveForeground: AppColors.lPrimaryForeground,
      border: AppColors.lBorder,
      input: AppColors.lInput,
      ring: AppColors.lRing,
      // Color de selección de texto: primary con 20% opacidad
      selection: Color(0x332F6EB5),
    ),
    radius: _borderRadius,
  );

  // ══════════════════════════════════════════════════════════════════════
  //  DARK
  // ══════════════════════════════════════════════════════════════════════
  static final ShadThemeData dark = ShadThemeData(
    brightness: Brightness.dark,
    colorScheme: const ShadColorScheme(
      background: AppColors.dBackground,
      foreground: AppColors.dForeground,
      card: AppColors.dCard,
      cardForeground: AppColors.dCardForeground,
      popover: AppColors.dPopover,
      popoverForeground: AppColors.dPopoverForeground,
      primary: AppColors.dPrimary,
      primaryForeground: AppColors.dPrimaryForeground,
      secondary: AppColors.dSecondary,
      secondaryForeground: AppColors.dSecondaryForeground,
      muted: AppColors.dMuted,
      mutedForeground: AppColors.dMutedForeground,
      accent: AppColors.dAccent,
      accentForeground: AppColors.dAccentForeground,
      destructive: AppColors.dDestructive,
      destructiveForeground: AppColors.dPrimaryForeground,
      border: AppColors.dBorder,
      input: AppColors.dInput,
      ring: AppColors.dRing,
      // Color de selección de texto: primary con 30% opacidad
      selection: Color(0x4D2A5A99),
    ),
    radius: _borderRadius,
  );
}
