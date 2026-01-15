import 'package:flutter/services.dart';
import '../models/fraud_data_model.dart';

class FraudDataService {
  static List<FraudData> _cachedData = [];

  static Future<List<FraudData>> getFraudData() async {
    if (_cachedData.isNotEmpty) {
      return _cachedData;
    }

    try {
      final String csvString = await rootBundle.loadString(
        'assets/data/fraud_by_state.csv',
      );
      final List<String> lines = csvString.split('\n');

      // Skip header and process data rows
      for (int i = 1; i < lines.length; i++) {
        final String line = lines[i].trim();
        if (line.isEmpty) continue;

        final List<String> columns = line.split(',');

        // Skip summary rows (Total State(s), Total UT(s), Total All India)
        if (columns.length >= 6 &&
            (columns[0].toLowerCase().contains('total') ||
                columns[1].toLowerCase().contains('total'))) {
          continue;
        }

        // Extract required columns: A (Si. No), C (State/UT), F (Fraud)
        if (columns.length >= 6) {
          final String serialNumber = columns[0].trim();
          final String stateName = columns[2].trim();
          final String fraudCount = columns[5].trim();

          // Skip rows with empty state names or fraud counts
          if (stateName.isNotEmpty && fraudCount.isNotEmpty) {
            try {
              final int fraudCases = int.parse(fraudCount);
              _cachedData.add(
                FraudData(
                  serialNumber: serialNumber,
                  stateName: stateName,
                  fraudCases: fraudCases,
                ),
              );
            } catch (e) {
              // Skip rows with invalid fraud numbers
              continue;
            }
          }
        }
      }

      return _cachedData;
    } catch (e) {
      throw Exception('Failed to load fraud data: $e');
    }
  }

  static Future<FraudData?> getFraudDataByState(String stateName) async {
    final List<FraudData> allData = await getFraudData();

    try {
      return allData.firstWhere(
        (data) => data.stateName.toLowerCase() == stateName.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  static List<FraudData> filterFraudData(List<FraudData> data, String query) {
    if (query.isEmpty) return data;

    final String lowerQuery = query.toLowerCase();
    return data.where((item) {
      return item.serialNumber.toLowerCase().contains(lowerQuery) ||
          item.stateName.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
