// Lokalni probni nalozi. LocalDatabase ih čuva između pokretanja.
class AuthService {
  static void Function()? onChanged;
  static bool get isAdmin => currentUser?['role'] == 'admin';
  static List<Map<String, String>> get users => _users
      .map(
        (u) => {
          for (final entry in u.entries)
            if (entry.key != 'password') entry.key: entry.value,
          'status': u['status'] ?? 'Aktivan',
          'phone': u['phone'] ?? '',
          'registeredAt': u['registeredAt'] ?? '2026-01-01',
        },
      )
      .toList();
  static void setBlocked(String email, bool blocked) {
    if (!isAdmin || email == currentUser?['email']) return;
    final user = _users.firstWhere((u) => u['email'] == email);
    user['status'] = blocked ? 'Blokiran' : 'Aktivan';
    onChanged?.call();
  }

  static List<Map<String, String>> exportUsers() => _users;
  static void restoreUsers(List<dynamic> data) {
    _users
      ..clear()
      ..addAll(data.map((u) => Map<String, String>.from(u as Map)));
  }

  static final List<Map<String, String>> _users = [
    {
      'name': 'Administrator',
      'email': 'admin',
      'password': 'admin123',
      'role': 'admin',
      'registeredAt': DateTime.now().toIso8601String(),
    },
    {
      'name': 'Kata Banči',
      'email': 'katabancsi@gmail.com',
      'password': 'mennifog04',
      'role': 'user',
      'registeredAt': DateTime.now().toIso8601String(),
    },
  ];
  static Map<String, String>? currentUser;
  static Iterable<String> get userEmails => _users
      .where((user) => user['role'] == 'user')
      .map((user) => user['email']!);

  static String? register(String name, String email, String password) {
    final normalizedEmail = email.trim().toLowerCase();
    if (_users.any((user) => user['email'] == normalizedEmail)) {
      return 'Nalog sa ovim imejlom već postoji.';
    }
    _users.add({
      'name': name.trim(),
      'email': normalizedEmail,
      'password': password,
      'role': 'user',
      'registeredAt': DateTime.now().toIso8601String(),
      'status': 'Aktivan',
    });
    onChanged?.call();
    return null;
  }

  static bool login(String email, String password) {
    currentUser = null;
    for (final user in _users) {
      if (user['email'] == email.trim().toLowerCase() &&
          user['password'] == password) {
        if (user['status'] == 'Blokiran') return false;
        currentUser = {
          'name': user['name']!,
          'email': user['email']!,
          'role': user['role']!,
        };
        return true;
      }
    }
    return false;
  }

  static void logout() => currentUser = null;
}
