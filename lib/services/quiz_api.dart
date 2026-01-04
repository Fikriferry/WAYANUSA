import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class QuizApi {
  // Use IP address instead of localhost for mobile devices
  // Change this to your computer's IP address when testing on mobile
  static const String baseUrl =
      "http://192.168.100.57:8000"; // Your computer's IP address

  // Get quiz levels
  static Future<List<Map<String, dynamic>>> getLevels() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse("$baseUrl/api/quiz/levels"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['levels']);
    } else {
      throw Exception("Failed to load levels");
    }
  }

  // Get questions for a level
  static Future<Map<String, dynamic>> getQuestions(int levelId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse("$baseUrl/api/quiz/get_questions?level=$levelId"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load questions");
    }
  }

  // Submit quiz result
  static Future<Map<String, dynamic>> submitQuiz({
    required int userId,
    required int levelId,
    required int score,
    required int totalQuestions,
    required List<Map<String, dynamic>> userAnswers,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse("$baseUrl/api/quiz/submit"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "user_id": userId,
        "level_id": levelId,
        "score": score,
        "total_questions": totalQuestions,
        "user_answers": userAnswers,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to submit quiz");
    }
  }

  // Get leaderboard data
  static Future<List<Map<String, dynamic>>> getLeaderboard(int levelId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Map levelId to levelName
    final levelNames = {
      1: 'Beginner',
      2: 'Intermediate',
      3: 'Advanced',
      4: 'Expert',
    };

    final levelName = levelNames[levelId] ?? 'Beginner';

    final response = await http.get(
      Uri.parse("$baseUrl/api/leaderboard?level=$levelName"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['leaderboard']);
    } else {
      // Fallback: return empty list if endpoint doesn't exist yet
      return [];
    }
  }

  // Get user profile for leaderboard
  static Future<Map<String, dynamic>?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return null;

    final response = await http.get(
      Uri.parse("$baseUrl/api/auth/profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }
}
