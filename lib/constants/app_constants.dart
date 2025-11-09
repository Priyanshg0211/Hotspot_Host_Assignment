import 'package:flutter/material.dart';

/// App Constants - Design System
class AppConstants {
  AppConstants._();

    // ===== FONT FAMILIES =====
  static const String fontFamilyPrimary = 'Space Grotesk';
  static const String fontFamilySpecial = 'Pacifico';

  /// Font Families
  static const String fontFamilyHeading1 = 'Space Grotesk';
  static const String fontFamilyHeading2 = 'Space Grotesk';
  static const String fontFamilyHeading3 = 'Space Grotesk';
  static const String fontFamilyHeading4 = 'Space Grotesk';
  static const String fontFamilyHeading5 = 'Space Grotesk';
  static const String fontFamilyBody = 'Space Grotesk';
  static const String fontFamilyBodyJP = 'Space Grotesk';
  static const String fontFamilyBodyJP2 = 'Space Grotesk';
  static const String fontFamilySmall = 'Space Grotesk';
  static const String fontFamilySmall2 = 'Space Grotesk';
  static const String fontFamilyLowercase = 'Space Grotesk';
  static const String fontFamilyLowercase2 = 'Space Grotesk';

  /// Font Weights
  static const FontWeight fontWeightBold = FontWeight.w700;
  static const FontWeight fontWeightRegular = FontWeight.w400;

  /// Font Sizes
  static const double fontSizeHeading1Bold = 64.0;
  static const double fontSizeHeading1Regular = 64.0;
  static const double fontSizeHeading2Bold = 48.0;
  static const double fontSizeHeading2Regular = 48.0;
  static const double fontSizeHeading3Bold = 32.0;
  static const double fontSizeHeading3Regular = 32.0;
  static const double fontSizeBodyBold = 24.0;
  static const double fontSizeBodyRegular = 24.0;
  static const double fontSizeBodyJPBold = 20.0;
  static const double fontSizeBodyJPRegular = 20.0;
  static const double fontSizeSmallBold = 16.0;
  static const double fontSizeSmallRegular = 16.0;
  static const double fontSizeLowercaseBold = 12.0;
  static const double fontSizeLowercaseRegular = 12.0;
  static const double fontSizeSpecial = 24.0;

  /// Line Heights
  static const double lineHeightHeading1 = 1.2;
  static const double lineHeightHeading2 = 1.2;
  static const double lineHeightHeading3 = 1.25;
  static const double lineHeightBody = 1.33;
  static const double lineHeightBodyJP = 1.4;
  static const double lineHeightSmall = 1.5;
  static const double lineHeightLowercase = 1.67;
  static const double lineHeightSpecial = 1.33;

  /// Letter Spacing
  static const double letterSpacingHeading1 = -2.0;
  static const double letterSpacingHeading2 = -1.5;
  static const double letterSpacingHeading3 = -1.0;
  static const double letterSpacingBody = -0.5;
  static const double letterSpacingBodyJP = -0.3;
  static const double letterSpacingSmall = 0.0;
  static const double letterSpacingLowercase = 0.2;
  static const double letterSpacingSpecial = 0.0;

  /// Paragraph Spacing
  static const double paragraphSpacingHeading1 = 64.0;
  static const double paragraphSpacingHeading2 = 48.0;
  static const double paragraphSpacingHeading3 = 32.0;
  static const double paragraphSpacingBody = 24.0;
  static const double paragraphSpacingBodyJP = 20.0;
  static const double paragraphSpacingSmall = 16.0;
  static const double paragraphSpacingLowercase = 12.0;
  static const double paragraphSpacingSpecial = 24.0;

  // ===== TEXT STYLES =====

  /// Heading 1 Bold
  static TextStyle get heading1Bold => const TextStyle(
        fontFamily: fontFamilyHeading1,
        fontSize: fontSizeHeading1Bold,
        fontWeight: fontWeightBold,
        height: lineHeightHeading1,
        letterSpacing: letterSpacingHeading1,
      );

  /// Heading 1 Regular
  static TextStyle get heading1Regular => const TextStyle(
        fontFamily: fontFamilyHeading1,
        fontSize: fontSizeHeading1Regular,
        fontWeight: fontWeightRegular,
        height: lineHeightHeading1,
        letterSpacing: letterSpacingHeading1,
      );

  /// Heading 2 Bold
  static TextStyle get heading2Bold => const TextStyle(
        fontFamily: fontFamilyHeading2,
        fontSize: fontSizeHeading2Bold,
        fontWeight: fontWeightBold,
        height: lineHeightHeading2,
        letterSpacing: letterSpacingHeading2,
      );

  /// Heading 2 Regular
  static TextStyle get heading2Regular => const TextStyle(
        fontFamily: fontFamilyHeading2,
        fontSize: fontSizeHeading2Regular,
        fontWeight: fontWeightRegular,
        height: lineHeightHeading2,
        letterSpacing: letterSpacingHeading2,
      );

  /// Heading 3 Bold
  static TextStyle get heading3Bold => const TextStyle(
        fontFamily: fontFamilyHeading3,
        fontSize: fontSizeHeading3Bold,
        fontWeight: fontWeightBold,
        height: lineHeightHeading3,
        letterSpacing: letterSpacingHeading3,
      );

  /// Heading 3 Regular
  static TextStyle get heading3Regular => const TextStyle(
        fontFamily: fontFamilyHeading3,
        fontSize: fontSizeHeading3Regular,
        fontWeight: fontWeightRegular,
        height: lineHeightHeading3,
        letterSpacing: letterSpacingHeading3,
      );

  /// Body Bold
  static TextStyle get bodyBold => const TextStyle(
        fontFamily: fontFamilyBody,
        fontSize: fontSizeBodyBold,
        fontWeight: fontWeightBold,
        height: lineHeightBody,
        letterSpacing: letterSpacingBody,
      );

  /// Body Regular
  static TextStyle get bodyRegular => const TextStyle(
        fontFamily: fontFamilyBody,
        fontSize: fontSizeBodyRegular,
        fontWeight: fontWeightRegular,
        height: lineHeightBody,
        letterSpacing: letterSpacingBody,
      );

  /// Body JP Bold
  static TextStyle get bodyJPBold => const TextStyle(
        fontFamily: fontFamilyBodyJP,
        fontSize: fontSizeBodyJPBold,
        fontWeight: fontWeightBold,
        height: lineHeightBodyJP,
        letterSpacing: letterSpacingBodyJP,
      );

  /// Body JP Regular
  static TextStyle get bodyJPRegular => const TextStyle(
        fontFamily: fontFamilyBodyJP,
        fontSize: fontSizeBodyJPRegular,
        fontWeight: fontWeightRegular,
        height: lineHeightBodyJP,
        letterSpacing: letterSpacingBodyJP,
      );

  /// Small Bold
  static TextStyle get smallBold => const TextStyle(
        fontFamily: fontFamilySmall,
        fontSize: fontSizeSmallBold,
        fontWeight: fontWeightBold,
        height: lineHeightSmall,
        letterSpacing: letterSpacingSmall,
      );

  /// Small Regular
  static TextStyle get smallRegular => const TextStyle(
        fontFamily: fontFamilySmall,
        fontSize: fontSizeSmallRegular,
        fontWeight: fontWeightRegular,
        height: lineHeightSmall,
        letterSpacing: letterSpacingSmall,
      );

  /// Lowercase Bold
  static TextStyle get lowercaseBold => const TextStyle(
        fontFamily: fontFamilyLowercase,
        fontSize: fontSizeLowercaseBold,
        fontWeight: fontWeightBold,
        height: lineHeightLowercase,
        letterSpacing: letterSpacingLowercase,
      );

  /// Lowercase Regular
  static TextStyle get lowercaseRegular => const TextStyle(
        fontFamily: fontFamilyLowercase,
        fontSize: fontSizeLowercaseRegular,
        fontWeight: fontWeightRegular,
        height: lineHeightLowercase,
        letterSpacing: letterSpacingLowercase,
      );

  /// Special Font (Pacifico)
  static TextStyle get special => const TextStyle(
        fontFamily: fontFamilySpecial,
        fontSize: fontSizeSpecial,
        fontWeight: fontWeightRegular,
        height: lineHeightSpecial,
        letterSpacing: letterSpacingSpecial,
      );

  // ===== COLORS =====

  /// Base Colors
  static const Color colorText = Color(0xFF1F1F1F);
  static const Color colorText2 = Color(0xFF3F3F3F);
  static const Color colorBone = Color(0xFFF5F5DC);
  static const Color colorBase = Color(0xFF282828);
  static const Color colorBase2 = Color(0xFF4F4F4F);

  /// Grayscale
  static const Color colorWhite = Color(0xFFFFFFFF);
  static const Color colorWhite2 = Color(0xFFF5F5F5);
  static const Color colorWhite3 = Color(0xFFE0E0E0);
  static const Color colorGray = Color(0xFFBDBDBD);
  static const Color colorGray2 = Color(0xFF9E9E9E);
  static const Color colorBlack = Color(0xFF1F1F1F);

  /// Accent Colors
  static const Color colorOutline = Color(0xFF1F1F1F);
  static const Color colorOutlineOffset = Color(0xFF4F4F4F);
  static const Color colorOutlineOffset2 = Color(0xFFD4C5B9);
  static const Color colorOutlineOffset3 = Color(0xFFE0D5CA);
  static const Color colorOutlineOffset4 = Color(0xFFF5E6D3);
  static const Color colorOutlineOffset5 = Color(0xFFF9F5F0);

  /// Brand Colors
  static const Color colorPrimary1 = Color(0xFF8B8AFF);
  static const Color colorPrimary2 = Color(0xFF6D6CFF);
  static const Color colorGreen = Color(0xFF00FF85);
  static const Color colorPink = Color(0xFFFF3366);

  /// Extended Palette
  static const Color colorBrown1 = Color(0xFF8B7355);
  static const Color colorBrown2 = Color(0xFF4F4F4F);
  static const Color colorBrown3 = Color(0xFFE0D5CA);
  static const Color colorBrown4 = Color(0xFFF5F5F5);
  static const Color colorGreenText = Color(0xFF00FF85);

  /// Opacity Variants (for Primary Colors)
  static const Color colorPrimary150 = Color(0x808B8AFF); // 50% opacity
  static const Color colorPrimary250 = Color(0x806D6CFF); // 50% opacity
  static const Color colorGreen50 = Color(0x8000FF85); // 50% opacity
  static const Color colorPink50 = Color(0x80FF3366); // 50% opacity

  // ===== COLOR SCHEMES =====

  /// Light Theme Colors
  static const ColorScheme lightColorScheme = ColorScheme.light(
    primary: colorPrimary1,
    secondary: colorPrimary2,
    surface: colorWhite,
    error: colorPink,
    onPrimary: colorWhite,
    onSecondary: colorWhite,
    onSurface: colorText,
    onError: colorWhite,
  );

  /// Dark Theme Colors (if needed)
  static const ColorScheme darkColorScheme = ColorScheme.dark(
    primary: colorPrimary1,
    secondary: colorPrimary2,
    surface: colorBase,
    error: colorPink,
    onPrimary: colorWhite,
    onSecondary: colorWhite,
    onSurface: colorWhite,
    onError: colorWhite,
  );

  // ===== SPACING =====

  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;

  // ===== BORDER RADIUS =====

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;



  static TextStyle getTextStyle(String styleName) {
    switch (styleName.toLowerCase()) {
      case 'heading1bold':
        return heading1Bold;
      case 'heading1regular':
        return heading1Regular;
      case 'heading2bold':
        return heading2Bold;
      case 'heading2regular':
        return heading2Regular;
      case 'heading3bold':
        return heading3Bold;
      case 'heading3regular':
        return heading3Regular;
      case 'bodybold':
        return bodyBold;
      case 'bodyregular':
        return bodyRegular;
      case 'bodyjpbold':
        return bodyJPBold;
      case 'bodyjpregular':
        return bodyJPRegular;
      case 'smallbold':
        return smallBold;
      case 'smallregular':
        return smallRegular;
      case 'lowercasebold':
        return lowercaseBold;
      case 'lowercaseregular':
        return lowercaseRegular;
      case 'special':
        return special;
      default:
        return bodyRegular;
    }
  }
}