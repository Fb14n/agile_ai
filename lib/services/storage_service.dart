import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agile_ai/models/message.dart';
import 'package:agile_ai/models/scrum_ceremony.dart';

class StorageService {
  static const String _messagesKey = 'messages';
  static const String _ceremoniesKey = 'ceremonies';
  static const String _apiKeyKey = 'api_key';

  Future<void> saveMessages(List<Message> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = messages.map((m) => m.toJson()).toList();
    await prefs.setString(_messagesKey, jsonEncode(jsonList));
  }

  Future<List<Message>> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_messagesKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Message.fromJson(json)).toList();
  }

  Future<void> saveCeremonies(List<ScrumCeremony> ceremonies) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = ceremonies.map((c) => c.toJson()).toList();
    await prefs.setString(_ceremoniesKey, jsonEncode(jsonList));
  }

  Future<List<ScrumCeremony>> loadCeremonies() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_ceremoniesKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => ScrumCeremony.fromJson(json)).toList();
  }

  Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, apiKey);
  }

  Future<String?> loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
