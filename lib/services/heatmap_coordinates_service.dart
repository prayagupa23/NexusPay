class HeatmapCoordinatesService {
  // Approximate coordinate mappings for Indian states on the heatmap
  // These coordinates are relative to the image dimensions (0.0 to 1.0)
  static const Map<String, Map<String, double>> _stateCoordinates = {
    'Andhra Pradesh': {'x': 0.55, 'y': 0.75},
    'Arunachal Pradesh': {'x': 0.85, 'y': 0.25},
    'Assam': {'x': 0.80, 'y': 0.35},
    'Bihar': {'x': 0.70, 'y': 0.45},
    'Chhattisgarh': {'x': 0.55, 'y': 0.55},
    'Goa': {'x': 0.35, 'y': 0.80},
    'Gujarat': {'x': 0.25, 'y': 0.45},
    'Haryana': {'x': 0.55, 'y': 0.35},
    'Himachal Pradesh': {'x': 0.45, 'y': 0.25},
    'Jharkhand': {'x': 0.65, 'y': 0.50},
    'Karnataka': {'x': 0.40, 'y': 0.75},
    'Kerala': {'x': 0.35, 'y': 0.85},
    'Madhya Pradesh': {'x': 0.50, 'y': 0.50},
    'Maharashtra': {'x': 0.40, 'y': 0.60},
    'Manipur': {'x': 0.88, 'y': 0.35},
    'Meghalaya': {'x': 0.82, 'y': 0.38},
    'Mizoram': {'x': 0.86, 'y': 0.42},
    'Nagaland': {'x': 0.86, 'y': 0.30},
    'Odisha': {'x': 0.65, 'y': 0.65},
    'Punjab': {'x': 0.45, 'y': 0.30},
    'Rajasthan': {'x': 0.35, 'y': 0.35},
    'Sikkim': {'x': 0.72, 'y': 0.38},
    'Tamil Nadu': {'x': 0.40, 'y': 0.85},
    'Telangana': {'x': 0.50, 'y': 0.65},
    'Tripura': {'x': 0.84, 'y': 0.40},
    'Uttar Pradesh': {'x': 0.60, 'y': 0.40},
    'Uttarakhand': {'x': 0.55, 'y': 0.30},
    'West Bengal': {'x': 0.70, 'y': 0.50},
    'A & N Islands': {'x': 0.90, 'y': 0.75},
    'Chandigarh': {'x': 0.55, 'y': 0.35},
    'D & N Haveli and Daman & Diu': {'x': 0.30, 'y': 0.55},
    'Delhi': {'x': 0.58, 'y': 0.35},
    'Jammu & Kashmir': {'x': 0.40, 'y': 0.15},
    'Ladakh': {'x': 0.30, 'y': 0.10},
    'Lakshadweep': {'x': 0.25, 'y': 0.75},
    'Puducherry': {'x': 0.42, 'y': 0.82},
  };

  // Tap tolerance for coordinate matching (in relative units)
  static const double _tapTolerance = 0.05;

  static String? findStateByCoordinates(
    double x,
    double y, {
    double tolerance = _tapTolerance,
  }) {
    for (final entry in _stateCoordinates.entries) {
      final coords = entry.value;
      final double distance = _calculateDistance(
        x,
        y,
        coords['x']!,
        coords['y']!,
      );

      if (distance <= tolerance) {
        return entry.key;
      }
    }
    return null;
  }

  static double _calculateDistance(double x1, double y1, double x2, double y2) {
    return ((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
  }

  static Map<String, double>? getStateCoordinates(String stateName) {
    return _stateCoordinates[stateName];
  }

  static List<String> getAllStates() {
    return _stateCoordinates.keys.toList();
  }
}
