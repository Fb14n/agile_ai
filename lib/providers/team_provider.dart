import 'package:flutter/foundation.dart';
import 'package:agile_ai/models/team_member.dart';
import 'package:agile_ai/services/database_service.dart';

class TeamProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  List<TeamMember> _members = [];
  bool _loaded = false;

  List<TeamMember> get members => List.unmodifiable(_members);

  TeamProvider() {
    _load();
  }

  Future<void> _load() async {
    _members = await _db.loadTeamMembers();
    _loaded = true;
    notifyListeners();
  }

  bool get isLoaded => _loaded;

  Future<void> addMember(TeamMember member) async {
    _members.add(member);
    await _db.saveTeamMember(member);
    notifyListeners();
  }

  Future<void> updateMember(TeamMember updated) async {
    final index = _members.indexWhere((m) => m.id == updated.id);
    if (index != -1) {
      _members[index] = updated;
      await _db.saveTeamMember(updated);
      notifyListeners();
    }
  }

  Future<void> removeMember(String id) async {
    _members.removeWhere((m) => m.id == id);
    await _db.deleteTeamMember(id);
    notifyListeners();
  }

  /// All member names as a string list (for AI context).
  List<String> get memberNames => _members.map((m) => m.name).toList();

  /// Comma-separated member list with roles.
  String get teamSummary => _members.isEmpty
      ? 'No team configured'
      : _members.map((m) => '${m.name} (${m.role})').join(', ');
}
