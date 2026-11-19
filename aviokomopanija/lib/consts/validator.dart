class MyValidators {
  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static String? displayNameValidator(String? value) =>
      value == null || value.trim().isEmpty ? 'Unesi ime.' : null;

  static String? emailValidator(String? value) =>
      value == null || !_emailPattern.hasMatch(value.trim())
      ? 'Unesi ispravan imejl.'
      : null;

  static String? loginEmailValidator(String? value) =>
      value?.trim().toLowerCase() == 'admin' ? null : emailValidator(value);

  static String? loginPasswordValidator(String? value) =>
      value == null || value.isEmpty ? 'Unesi lozinku.' : null;

  static String? passwordValidator(String? value) =>
      value == null || value.length < 6 ? 'Unesi najmanje 6 znakova.' : null;

  static String? repeatPasswordValidator(String? value, String password) =>
      value != password ? 'Lozinke se ne podudaraju.' : null;
}
