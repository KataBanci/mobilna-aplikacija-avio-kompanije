// Samo demonstracija u memoriji. Za stvarne naloge koristimo Firebase.
class AuthService {
  static final List<Map<String, String>> _users = [
    {
      'name': 'Administrator',
      'email': 'admin',
      'password': 'admin123',
      'role': 'admin',
    },
    {
      'name': 'Kata Banči',
      'email': 'katabancsi@gmail.com',
      'password': 'mennifog04',
      'role': 'user',
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
    });
    return null;
  }

  static bool login(String email, String password) {
    for (final user in _users) {
      if (user['email'] == email.trim().toLowerCase() &&
          user['password'] == password) {
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
