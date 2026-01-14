import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PhoneValidationService {
  static const String _apiKey = 'num_live_lrpyWXll0KGW1QobUs1J2haSF97OGxOGqmuIdHFH';
  static const String _baseUrl = 'https://api.numlookupapi.com/v1/validate';

  Future<Map<String, dynamic>?> validatePhoneNumber(String phoneNumber) async {
    try {
      // Ensure phone number has country code (default to +91 for India if not provided)
      String formattedNumber = phoneNumber.trim();
      if (!formattedNumber.startsWith('+')) {
        // Add +91 if no country code is present
        if (formattedNumber.startsWith('0')) {
          formattedNumber = '+91${formattedNumber.substring(1)}';
        } else if (formattedNumber.length == 10) {
          formattedNumber = '+91$formattedNumber';
        }
      }

      // Remove any non-digit characters except the leading +
      formattedNumber = formattedNumber.replaceAll(RegExp(r'[^\d+]'), '');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/$formattedNumber?apikey=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        debugPrint('Phone validation API error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error validating phone number: $e');
      return null;
    }
  }

  int calculateHonorScore(Map<String, dynamic> validationData) {
    int score = 0;

    // Valid Phone Number = +30
    if (validationData['valid'] == true) {
      score += 30;
    }

    // Indian Number = +20
    if (validationData['country_code'] == 'IN') {
      score += 20;
    }

    // Line type (mobile) = +20
    if (validationData['line_type'] == 'mobile') {
      score += 20;
    }

    // Known Carrier = +10
    final carrier = validationData['carrier']?.toString() ?? '';
    if (carrier.contains('Vodafone Idea Ltd') || 
        carrier.contains('Reliance Jio Infocomm Ltd')) {
      score += 10;
    }

    // New account penalty = -10
    score -= 10;

    // Ensure score is not negative
    return score < 0 ? 0 : score;
  }
}
