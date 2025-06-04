import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart'; // Uncomment if using Google Maps

class CircuitCoordinates {
  // Koordinat lengkap circuit Formula 1
  static const Map<String, LatLng> coordinates = {
    // Musim 2024 Calendar
    'albert_park': LatLng(-37.8497, 144.9680), // Australian GP - Melbourne
    'bahrein': LatLng(26.0325, 50.5106), // Bahrain GP - Sakhir
    'shangai': LatLng(31.3389, 121.2277), // Chinese GP - Shanghai
    'baku': LatLng(40.3725, 49.8533), // Azerbaijan GP - Baku
    'miami': LatLng(25.9581, -80.2389), // Miami GP - Miami Gardens
    'imola': LatLng(44.3439, 11.7167), // Emilia Romagna GP - Imola
    'monaco': LatLng(43.7347, 7.4206), // Monaco GP - Monte Carlo
    'montmelo': LatLng(41.5700, 2.2611), // Spanish GP - Barcelona
    'gilles_villeneuve': LatLng(45.5000, -73.5228), // Canadian GP - Montreal
    'red_bull_ring': LatLng(47.2197, 14.7647), // Austrian GP - Spielberg
    'silverstone': LatLng(52.0786, -1.0169), // British GP - Silverstone
    'hungaroring': LatLng(47.5789, 19.2486), // Hungarian GP - Budapest
    'spa': LatLng(50.4372, 5.9711), // Belgian GP - Spa-Francorchamps
    'zandvoort': LatLng(52.3888, 4.5409), // Dutch GP - Zandvoort
    'monza': LatLng(45.6156, 9.2811), // Italian GP - Monza
    'marina_bay': LatLng(1.2914, 103.8640), // Singapore GP - Singapore
    'suzuka': LatLng(34.8431, 136.5414), // Japanese GP - Suzuka
    'lusail': LatLng(25.4900, 51.4542), // Qatar GP - Lusail
    'austin': LatLng(30.1328, -97.6411), // US GP - Austin
    'hermanos_rodriguez': LatLng(19.4042, -99.0907), // Mexico GP - Mexico City
    'interlagos': LatLng(-23.7036, -46.6997), // Brazilian GP - São Paulo
    'vegas': LatLng(36.1147, -115.1728), // Las Vegas GP - Las Vegas
    'yas_marina': LatLng(24.4672, 54.6031), // Abu Dhabi GP - Abu Dhabi
    'jeddah': LatLng(21.6319, 39.1044), // Saudi Arabian GP - Jeddah
    'hockenheim': LatLng(49.3278, 8.5656), // German GP - Hockenheim
    'nurburgring': LatLng(50.3356, 6.9475), // Eifel GP - Nürburgring
    'mugello': LatLng(43.9975, 11.3719), // Tuscan GP - Mugello
    'sochi': LatLng(43.4057, 39.9608), // Russian GP - Sochi
    'istanbul': LatLng(40.9517, 29.4058), // Turkish GP - Istanbul
    'portimao': LatLng(37.2272, -8.6267), // Portuguese GP - Portimão
    'paul_ricard': LatLng(43.2506, 5.7914), // French GP - Paul Ricard
    
  };
  
  // Method untuk mendapatkan koordinat berdasarkan circuit ID
  static LatLng? getCoordinates(String circuitId) {
    return coordinates[circuitId];
  }
  
  // Method untuk mendapatkan semua circuit yang memiliki koordinat
  static List<String> getAvailableCircuits() {
    return coordinates.keys.toList();
  }
  
  // Method untuk mengecek apakah circuit memiliki koordinat
  static bool hasCoordinates(String circuitId) {
    return coordinates.containsKey(circuitId);
  }
  
  // Method untuk mendapatkan region berdasarkan koordinat
  static String getRegion(String circuitId) {
    final coord = coordinates[circuitId];
    if (coord == null) return 'Unknown';
    
    final lat = coord.latitude;
    final lng = coord.longitude;
    
    // Europe
    if (lat > 35 && lat < 72 && lng > -10 && lng < 40) {
      return 'Europe';
    }
    // Asia
    else if (lat > 10 && lat < 55 && lng > 70 && lng < 180) {
      return 'Asia';
    }
    // Middle East
    else if (lat > 12 && lat < 42 && lng > 25 && lng < 70) {
      return 'Middle East';
    }
    // North America
    else if (lat > 15 && lat < 72 && lng > -170 && lng < -50) {
      return 'North America';
    }
    // South America
    else if (lat > -60 && lat < 15 && lng > -85 && lng < -30) {
      return 'South America';
    }
    // Oceania
    else if (lat > -50 && lat < 0 && lng > 110 && lng < 180) {
      return 'Oceania';
    }
    // Africa
    else if (lat > -35 && lat < 40 && lng > -20 && lng < 55) {
      return 'Africa';
    }
    
    return 'Other';
  }
  // Method untuk mendapatkan batas region untuk zoom
  static MapPosition getRegionBounds(String region) {
    switch (region) {
      case 'Europe':
        return MapPosition(center: LatLng(50.0, 10.0), zoom: 4.0);
      case 'Asia':
        return MapPosition(center: LatLng(35.0, 105.0), zoom: 3.0);
      case 'Middle East':
        return MapPosition(center: LatLng(25.0, 45.0), zoom: 5.0);
      case 'North America':
        return MapPosition(center: LatLng(45.0, -100.0), zoom: 3.0);
      case 'South America':
        return MapPosition(center: LatLng(-15.0, -60.0), zoom: 3.0);
      case 'Oceania':
        return MapPosition(center: LatLng(-25.0, 140.0), zoom: 4.0);
      case 'Africa':
        return MapPosition(center: LatLng(0.0, 20.0), zoom: 3.0);
      default:
        return MapPosition(center: LatLng(0.0, 0.0), zoom: 2.0);
  }
  }
}