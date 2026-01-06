import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipient_honor_score_model.dart';

class RemoteHonorScoreService {
  static const String _baseUrl = 'YOUR_SUPABASE_URL/rest/v1';
  static const String _apiKey = 'YOUR_SUPABASE_ANON_KEY';
  
  final String _userId;
  
  RemoteHonorScoreService(this._userId);
  
  // Get headers for API requests
  Map<String, String> get _headers => {
    'apikey': _apiKey,
    'Authorization': 'Bearer $_apiKey',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation',
  };
  
  // Save or update honor score
  Future<bool> saveHonorScore(RecipientHonorScore score) async {
    try {
      final url = '$_baseUrl/recipient_honor_scores?user_id=eq.${score.userId}&number_id=eq.${Uri.encodeComponent(score.numberId)}';
      
      // Check if record exists
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      final bool recordExists = response.statusCode == 200 && 
          jsonDecode(response.body) is List && 
          (jsonDecode(response.body) as List).isNotEmpty;
      
      final http.Response upsertResponse;
      
      if (recordExists) {
        // Update existing record
        upsertResponse = await http.patch(
          Uri.parse(url),
          headers: _headers,
          body: jsonEncode({
            'honor_score': score.honorScore,
          }),
        );
      } else {
        // Insert new record
        upsertResponse = await http.post(
          Uri.parse('$_baseUrl/recipient_honor_scores'),
          headers: _headers,
          body: jsonEncode({
            'user_id': score.userId,
            'number_id': score.numberId,
            'honor_score': score.honorScore,
          }),
        );
      }
      
      return upsertResponse.statusCode == 200 || upsertResponse.statusCode == 201;
    } catch (e) {
      print('Error saving honor score: $e');
      return false;
    }
  }
  
  // Get all scores for current user
  Future<List<RecipientHonorScore>> getAllScores() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/recipient_honor_scores?user_id=eq.$_userId&select=*'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => RecipientHonorScore.fromMap({
                  'id': json['id'],
                  'user_id': json['user_id'],
                  'number_id': json['number_id'],
                  'honor_score': json['honor_score'],
                }))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting honor scores: $e');
      return [];
    }
  }
  
  // Get score for a specific number
  Future<RecipientHonorScore?> getScore(String numberId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/recipient_honor_scores?user_id=eq.$_userId&number_id=eq.${Uri.encodeComponent(numberId)}'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return RecipientHonorScore.fromMap({
            'id': data[0]['id'],
            'user_id': data[0]['user_id'],
            'number_id': data[0]['number_id'],
            'honor_score': data[0]['honor_score'],
          });
        }
      }
      return null;
    } catch (e) {
      print('Error getting honor score: $e');
      return null;
    }
  }
  
  // Delete a score
  Future<bool> deleteScore(String numberId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/recipient_honor_scores?user_id=eq.$_userId&number_id=eq.${Uri.encodeComponent(numberId)}'),
        headers: _headers,
      );
      
      return response.statusCode == 204;
    } catch (e) {
      print('Error deleting honor score: $e');
      return false;
    }
  }
}
