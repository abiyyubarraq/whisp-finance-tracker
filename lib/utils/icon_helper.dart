// lib/utils/icon_helper.dart
import 'package:flutter/material.dart';

/// Helper class for managing icon mappings
class IconHelper {
  /// Map of icon string identifiers to IconData
  static final Map<String, IconData> availableIcons = {
    'restaurant': Icons.restaurant_rounded,
    'coffee': Icons.coffee_rounded,
    'directions_car': Icons.directions_car_rounded,
    'bolt': Icons.bolt_rounded,
    'shopping_bag': Icons.shopping_bag_rounded,
    'movie': Icons.movie_rounded,
    'favorite': Icons.favorite_rounded,
    'school': Icons.school_rounded,
    'home': Icons.home_rounded,
    'flight': Icons.flight_rounded,
    'hotel': Icons.hotel_rounded,
    'local_hospital': Icons.local_hospital_rounded,
    'fitness_center': Icons.fitness_center_rounded,
    'sports_esports': Icons.sports_esports_rounded,
    'music_note': Icons.music_note_rounded,
    'phone': Icons.phone_rounded,
    'wifi': Icons.wifi_rounded,
    'pets': Icons.pets_rounded,
    'child_care': Icons.child_care_rounded,
    'local_gas_station': Icons.local_gas_station_rounded,
    'shopping_cart': Icons.shopping_cart_rounded,
    'card_giftcard': Icons.card_giftcard_rounded,
    'beach_access': Icons.beach_access_rounded,
    'spa': Icons.spa_rounded,
    'local_pharmacy': Icons.local_pharmacy_rounded,
    'book': Icons.book_rounded,
    'brush': Icons.brush_rounded,
    'build': Icons.build_rounded,
    'celebration': Icons.celebration_rounded,
    'checkroom': Icons.checkroom_rounded,
    'more_horiz': Icons.more_horiz_rounded,
  };

  /// Get IconData from string identifier
  /// Returns a default icon if the identifier is not found
  static IconData getIconFromString(String iconString) {
    return availableIcons[iconString] ?? Icons.receipt_rounded;
  }

  /// Get string identifier from IconData
  /// Returns 'more_horiz' if no match is found
  static String getStringFromIcon(IconData icon) {
    final entry = availableIcons.entries.firstWhere(
      (entry) => entry.value == icon,
      orElse: () => MapEntry('more_horiz', Icons.more_horiz_rounded),
    );
    return entry.key;
  }

  /// Get a list of all available icon identifiers
  static List<String> getAllIconIdentifiers() {
    return availableIcons.keys.toList();
  }

  /// Get a categorized map of icons for better organization in UI
  static Map<String, List<MapEntry<String, IconData>>> getCategorizedIcons() {
    return {
      'Food & Drinks': [
        MapEntry('restaurant', Icons.restaurant_rounded),
        MapEntry('coffee', Icons.coffee_rounded),
      ],
      'Transportation': [
        MapEntry('directions_car', Icons.directions_car_rounded),
        MapEntry('local_gas_station', Icons.local_gas_station_rounded),
        MapEntry('flight', Icons.flight_rounded),
      ],
      'Shopping': [
        MapEntry('shopping_bag', Icons.shopping_bag_rounded),
        MapEntry('shopping_cart', Icons.shopping_cart_rounded),
        MapEntry('card_giftcard', Icons.card_giftcard_rounded),
      ],
      'Entertainment': [
        MapEntry('movie', Icons.movie_rounded),
        MapEntry('sports_esports', Icons.sports_esports_rounded),
        MapEntry('music_note', Icons.music_note_rounded),
        MapEntry('beach_access', Icons.beach_access_rounded),
      ],
      'Health & Fitness': [
        MapEntry('local_hospital', Icons.local_hospital_rounded),
        MapEntry('fitness_center', Icons.fitness_center_rounded),
        MapEntry('local_pharmacy', Icons.local_pharmacy_rounded),
        MapEntry('spa', Icons.spa_rounded),
      ],
      'Home & Utilities': [
        MapEntry('home', Icons.home_rounded),
        MapEntry('bolt', Icons.bolt_rounded),
        MapEntry('wifi', Icons.wifi_rounded),
        MapEntry('phone', Icons.phone_rounded),
      ],
      'Education & Personal': [
        MapEntry('school', Icons.school_rounded),
        MapEntry('book', Icons.book_rounded),
        MapEntry('favorite', Icons.favorite_rounded),
        MapEntry('child_care', Icons.child_care_rounded),
        MapEntry('pets', Icons.pets_rounded),
      ],
      'Others': [
        MapEntry('hotel', Icons.hotel_rounded),
        MapEntry('brush', Icons.brush_rounded),
        MapEntry('build', Icons.build_rounded),
        MapEntry('celebration', Icons.celebration_rounded),
        MapEntry('checkroom', Icons.checkroom_rounded),
        MapEntry('more_horiz', Icons.more_horiz_rounded),
      ],
    };
  }
}
