import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PhoneVerificationService {
  static const String _apiKey = 'num_live_lrpyWXll0KGW1QobUs1J2haSF97OGxOGqmuIdHFH';
  static const String _baseUrl = 'https://api.numlookupapi.com/v1/validate';

  /// Validates a phone number using Numlookup API
  /// Returns phone verification data or null if validation fails
  Future<PhoneVerificationResult?> validatePhoneNumber(String phoneNumber) async {
    try {
      // Ensure phone number starts with +
      final formattedNumber = phoneNumber.startsWith('+') ? phoneNumber : '+$phoneNumber';
      
      final url = Uri.parse('$_baseUrl/$formattedNumber?apikey=$_apiKey');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        
        return PhoneVerificationResult.fromMap(data);
      } else {
        debugPrint('Phone verification API error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error validating phone number: $e');
      return null;
    }
  }

  /// Extracts phone number from UPI ID
  /// UPI IDs are typically in format: phone@bank or name@bank
  /// Returns phone number if found, null otherwise
  String? extractPhoneFromUpiId(String upiId) {
    try {
      // UPI ID format: phone@bank or name@bank
      final parts = upiId.split('@');
      if (parts.isEmpty) return null;
      
      final firstPart = parts[0];
      
      // Check if first part is a phone number (digits only, typically 10 digits)
      if (RegExp(r'^\d{10}$').hasMatch(firstPart)) {
        return '+91$firstPart'; // Assuming Indian numbers
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
}

class PhoneVerificationResult {
  final bool valid;
  final String? number;
  final String? localFormat;
  final String? internationalFormat;
  final String? countryPrefix;
  final String? countryCode;
  final String? countryName;
  final String? location;
  final String? carrier;
  final String? lineType;

  PhoneVerificationResult({
    required this.valid,
    this.number,
    this.localFormat,
    this.internationalFormat,
    this.countryPrefix,
    this.countryCode,
    this.countryName,
    this.location,
    this.carrier,
    this.lineType,
  });

  factory PhoneVerificationResult.fromMap(Map<String, dynamic> map) {
    return PhoneVerificationResult(
      valid: map['valid'] as bool? ?? false,
      number: map['number'] as String?,
      localFormat: map['local_format'] as String?,
      internationalFormat: map['international_format'] as String?,
      countryPrefix: map['country_prefix'] as String?,
      countryCode: map['country_code'] as String?,
      countryName: map['country_name'] as String?,
      location: map['location'] as String?,
      carrier: map['carrier'] as String?,
      lineType: map['line_type'] as String?,
    );
  }
}

