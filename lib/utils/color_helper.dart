// lib/utils/color_helper.dart
import 'package:flutter/material.dart';

/// Helper class for managing color utilities and conversions
class ColorHelper {
  /// Predefined colors for spent types (Tailwind CSS inspired)
  static const List<String> predefinedColors = [
    '#EF4444', // Red
    '#F97316', // Orange
    '#F59E0B', // Amber
    '#EAB308', // Yellow
    '#84CC16', // Lime
    '#22C55E', // Green
    '#10B981', // Emerald
    '#14B8A6', // Teal
    '#06B6D4', // Cyan
    '#0EA5E9', // Sky
    '#3B82F6', // Blue
    '#6366F1', // Indigo
    '#8B5CF6', // Violet
    '#A855F7', // Purple
    '#D946EF', // Fuchsia
    '#EC4899', // Pink
    '#F43F5E', // Rose
    '#64748B', // Slate
    '#6B7280', // Gray
    '#78716C', // Stone
  ];

  /// Parse hex color string to Color object
  /// Returns gray color if parsing fails
  ///
  /// Example:
  /// ```dart
  /// Color red = ColorHelper.parseColor('#EF4444');
  /// Color blue = ColorHelper.parseColor('3B82F6'); // Also works without #
  /// ```
  static Color parseColor(String colorString) {
    try {
      String hexColor = colorString.trim();

      // Remove # if present
      if (hexColor.startsWith('#')) {
        hexColor = hexColor.substring(1);
      }

      // Ensure we have a valid 6 or 8 character hex string
      if (hexColor.length == 6) {
        return Color(int.parse('FF$hexColor', radix: 16));
      } else if (hexColor.length == 8) {
        return Color(int.parse(hexColor, radix: 16));
      } else {
        return Colors.grey;
      }
    } catch (e) {
      return Colors.grey;
    }
  }

  /// Convert Color to hex string (uppercase)
  ///
  /// Example:
  /// ```dart
  /// String hex = ColorHelper.colorToHex(Colors.red); // Returns '#F44336'
  /// ```
  static String colorToHex(Color color) {
    final r = (color.r * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0');
    return '#$r$g$b'.toUpperCase();
  }

  /// Convert Color to hex string (lowercase)
  static String colorToHexLowerCase(Color color) {
    final r = (color.r * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0');
    return '#$r$g$b'.toLowerCase();
  }

  /// Get a categorized map of colors with names for better UI organization
  static Map<String, List<Map<String, dynamic>>> getCategorizedColors() {
    return {
      'Reds & Pinks': [
        {'hex': '#EF4444', 'name': 'Red', 'description': 'Vibrant red'},
        {'hex': '#F43F5E', 'name': 'Rose', 'description': 'Romantic rose'},
        {'hex': '#EC4899', 'name': 'Pink', 'description': 'Bright pink'},
        {'hex': '#D946EF', 'name': 'Fuchsia', 'description': 'Bold fuchsia'},
      ],
      'Oranges & Yellows': [
        {'hex': '#F97316', 'name': 'Orange', 'description': 'Warm orange'},
        {'hex': '#F59E0B', 'name': 'Amber', 'description': 'Golden amber'},
        {'hex': '#EAB308', 'name': 'Yellow', 'description': 'Sunny yellow'},
      ],
      'Greens': [
        {'hex': '#84CC16', 'name': 'Lime', 'description': 'Fresh lime'},
        {'hex': '#22C55E', 'name': 'Green', 'description': 'Classic green'},
        {'hex': '#10B981', 'name': 'Emerald', 'description': 'Rich emerald'},
        {'hex': '#14B8A6', 'name': 'Teal', 'description': 'Cool teal'},
      ],
      'Blues': [
        {'hex': '#06B6D4', 'name': 'Cyan', 'description': 'Bright cyan'},
        {'hex': '#0EA5E9', 'name': 'Sky', 'description': 'Sky blue'},
        {'hex': '#3B82F6', 'name': 'Blue', 'description': 'Pure blue'},
        {'hex': '#6366F1', 'name': 'Indigo', 'description': 'Deep indigo'},
      ],
      'Purples': [
        {'hex': '#8B5CF6', 'name': 'Violet', 'description': 'Royal violet'},
        {'hex': '#A855F7', 'name': 'Purple', 'description': 'Mystic purple'},
      ],
      'Neutrals': [
        {
          'hex': '#64748B',
          'name': 'Slate',
          'description': 'Professional slate',
        },
        {'hex': '#6B7280', 'name': 'Gray', 'description': 'Neutral gray'},
        {'hex': '#78716C', 'name': 'Stone', 'description': 'Earthy stone'},
      ],
    };
  }

  /// Get all color entries as a flat list
  static List<Map<String, dynamic>> getAllColors() {
    final categorized = getCategorizedColors();
    final List<Map<String, dynamic>> allColors = [];

    categorized.forEach((category, colors) {
      allColors.addAll(colors);
    });

    return allColors;
  }

  /// Check if a color is light or dark for contrast calculations
  /// Returns true if the color is light (luminance > 0.5)
  static bool isLightColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5;
  }

  /// Get contrasting text color (black or white) for a given background color
  /// This is useful for ensuring text is readable on any background
  ///
  /// Example:
  /// ```dart
  /// Color bgColor = Colors.blue;
  /// Color textColor = ColorHelper.getContrastColor(bgColor); // Returns white
  /// ```
  static Color getContrastColor(Color backgroundColor) {
    return isLightColor(backgroundColor) ? Colors.black : Colors.white;
  }

  /// Get contrasting text color with custom threshold
  static Color getContrastColorWithThreshold(
    Color backgroundColor,
    double threshold,
  ) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > threshold ? Colors.black : Colors.white;
  }

  /// Generate a lighter shade of a color
  /// Amount should be between 0.0 and 1.0
  ///
  /// Example:
  /// ```dart
  /// Color lightBlue = ColorHelper.lighten(Colors.blue, 0.2);
  /// ```
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');

    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );

    return hslLight.toColor();
  }

  /// Generate a darker shade of a color
  /// Amount should be between 0.0 and 1.0
  ///
  /// Example:
  /// ```dart
  /// Color darkBlue = ColorHelper.darken(Colors.blue, 0.2);
  /// ```
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  /// Adjust the saturation of a color
  /// Amount should be between -1.0 (desaturate) and 1.0 (saturate)
  static Color adjustSaturation(Color color, double amount) {
    assert(amount >= -1 && amount <= 1, 'Amount must be between -1 and 1');

    final hsl = HSLColor.fromColor(color);
    final newSaturation = (hsl.saturation + amount).clamp(0.0, 1.0);

    return hsl.withSaturation(newSaturation).toColor();
  }

  /// Get complementary color on the color wheel (opposite color)
  ///
  /// Example:
  /// ```dart
  /// Color orange = ColorHelper.getComplementaryColor(Colors.blue);
  /// ```
  static Color getComplementaryColor(Color color) {
    final hsl = HSLColor.fromColor(color);
    final complementaryHue = (hsl.hue + 180) % 360;
    return hsl.withHue(complementaryHue).toColor();
  }

  /// Get analogous colors (colors next to it on the color wheel)
  /// Returns a list of [leftColor, originalColor, rightColor]
  static List<Color> getAnalogousColors(Color color, {double angle = 30}) {
    final hsl = HSLColor.fromColor(color);

    return [
      hsl.withHue((hsl.hue - angle) % 360).toColor(),
      color,
      hsl.withHue((hsl.hue + angle) % 360).toColor(),
    ];
  }

  /// Get triadic colors (evenly spaced on color wheel)
  /// Returns a list of 3 colors including the original
  static List<Color> getTriadicColors(Color color) {
    final hsl = HSLColor.fromColor(color);

    return [
      color,
      hsl.withHue((hsl.hue + 120) % 360).toColor(),
      hsl.withHue((hsl.hue + 240) % 360).toColor(),
    ];
  }

  /// Get split complementary colors
  /// Returns [leftColor, originalColor, rightColor]
  static List<Color> getSplitComplementaryColors(
    Color color, {
    double angle = 30,
  }) {
    final hsl = HSLColor.fromColor(color);
    final complementaryHue = (hsl.hue + 180) % 360;

    return [
      hsl.withHue((complementaryHue - angle) % 360).toColor(),
      color,
      hsl.withHue((complementaryHue + angle) % 360).toColor(),
    ];
  }

  /// Validate if a hex color string is valid
  ///
  /// Example:
  /// ```dart
  /// bool valid = ColorHelper.isValidHexColor('#EF4444'); // true
  /// bool invalid = ColorHelper.isValidHexColor('not-a-color'); // false
  /// ```
  static bool isValidHexColor(String hexColor) {
    final hexColorPattern = RegExp(r'^#?([0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$');
    return hexColorPattern.hasMatch(hexColor);
  }

  /// Blend two colors together with a given ratio
  /// Ratio should be between 0.0 (100% color1) and 1.0 (100% color2)
  static Color blendColors(Color color1, Color color2, double ratio) {
    assert(ratio >= 0 && ratio <= 1, 'Ratio must be between 0 and 1');

    final r1 = (color1.r * 255.0).round().clamp(0, 255);
    final g1 = (color1.g * 255.0).round().clamp(0, 255);
    final b1 = (color1.b * 255.0).round().clamp(0, 255);
    final a1 = (color1.a * 255.0).round().clamp(0, 255);

    final r2 = (color2.r * 255.0).round().clamp(0, 255);
    final g2 = (color2.g * 255.0).round().clamp(0, 255);
    final b2 = (color2.b * 255.0).round().clamp(0, 255);
    final a2 = (color2.a * 255.0).round().clamp(0, 255);

    final r = (r1 * (1 - ratio) + r2 * ratio).round();
    final g = (g1 * (1 - ratio) + g2 * ratio).round();
    final b = (b1 * (1 - ratio) + b2 * ratio).round();
    final a = (a1 * (1 - ratio) + a2 * ratio).round();

    return Color.fromARGB(a, r, g, b);
  }

  /// Convert color to grayscale
  static Color toGrayscale(Color color) {
    final r = (color.r * 255.0).round().clamp(0, 255);
    final g = (color.g * 255.0).round().clamp(0, 255);
    final b = (color.b * 255.0).round().clamp(0, 255);
    final a = (color.a * 255.0).round().clamp(0, 255);

    final gray = (0.299 * r + 0.587 * g + 0.114 * b).round();
    return Color.fromARGB(a, gray, gray, gray);
  }

  /// Get color with adjusted opacity/alpha
  /// Opacity should be between 0.0 (transparent) and 1.0 (opaque)
  static Color withOpacity(Color color, double opacity) {
    assert(opacity >= 0 && opacity <= 1, 'Opacity must be between 0 and 1');
    return color.withValues(alpha: opacity);
  }

  /// Generate a random color from predefined colors
  static String getRandomPredefinedColor() {
    final random =
        (DateTime.now().millisecondsSinceEpoch % predefinedColors.length);
    return predefinedColors[random];
  }

  /// Get the color name from hex value (if it exists in predefined colors)
  static String? getColorName(String hexColor) {
    final categorized = getCategorizedColors();

    for (var category in categorized.values) {
      for (var colorData in category) {
        if (colorData['hex'].toLowerCase() == hexColor.toLowerCase()) {
          return colorData['name'] as String;
        }
      }
    }

    return null;
  }

  /// Check if a hex color exists in predefined colors
  static bool isPredefinedColor(String hexColor) {
    return predefinedColors.any(
      (color) => color.toLowerCase() == hexColor.toLowerCase(),
    );
  }

  /// Get Material Design color swatch from a single color
  static MaterialColor createMaterialColor(Color color) {
    final strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = (color.r * 255.0).round().clamp(0, 255);
    final int g = (color.g * 255.0).round().clamp(0, 255);
    final int b = (color.b * 255.0).round().clamp(0, 255);

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    // Create the primary color value as an int (ARGB format)
    final primaryValue = 0xFF000000 | (r << 16) | (g << 8) | b;
    return MaterialColor(primaryValue, swatch);
  }
}
