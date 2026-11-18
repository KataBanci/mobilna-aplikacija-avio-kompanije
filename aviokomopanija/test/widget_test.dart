import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aviokomopanija/main.dart';
import 'package:aviokomopanija/services/auth_service.dart';

void main() {
  test('Probni nalozi ostaju dostupni nakon odjave', () {
    expect(AuthService.login('admin', 'pogresna'), isFalse);
    expect(AuthService.login('admin', 'admin123'), isTrue);
    expect(AuthService.currentUser?['role'], 'admin');
    AuthService.logout();
    expect(AuthService.login('katabancsi@gmail.com', 'mennifog04'), isTrue);
    expect(AuthService.currentUser?['role'], 'user');
    AuthService.logout();
    expect(AuthService.login('admin', 'admin123'), isTrue);
    AuthService.logout();
    expect(AuthService.register('Drugi admin', 'admin', 'test123'), isNotNull);
  });
  testWidgets('Registracija, prijava, profil i odjava', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.widgetWithText(OutlinedButton, 'Registracija'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Registruj se'));
    await tester.pumpAndSettle();
    expect(find.text('Unesi ime.'), findsOneWidget);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Test Putnik');
    await tester.enterText(fields.at(1), 'putnik@example.com');
    await tester.enterText(fields.at(2), 'probna123');
    await tester.enterText(fields.at(3), 'probna123');
    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Registruj se'),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Registruj se'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'putnik@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'pogresna');
    await tester.tap(find.widgetWithText(FilledButton, 'Prijavi se'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Imejl ili lozinka nisu ispravni.'),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'probna123');
    await tester.tap(find.widgetWithText(FilledButton, 'Prijavi se'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Test Putnik'), findsOneWidget);
    await tester.tap(find.text('Lični podaci'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Novi Putnik');
    await tester.tap(find.widgetWithText(FilledButton, 'Sačuvaj'));
    await tester.pumpAndSettle();
    expect(find.text('Novi Putnik'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.tap(find.widgetWithText(NavigationDestination, 'Putovanja'));
    await tester.pumpAndSettle();
    expect(find.text('Vaša putovanja'), findsOneWidget);
    await tester.tap(find.widgetWithText(NavigationDestination, 'Profil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sačuvani putnici'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dodaj putnika'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Ana');
    await tester.enterText(find.byType(TextFormField).at(1), 'Petrović');
    await tester.tap(find.text('Sačuvaj'));
    await tester.pumpAndSettle();
    expect(find.text('Ana Petrović'), findsOneWidget);
    expect(AuthService.savedPassengers.single['first'], 'Ana');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Načini plaćanja'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('PayPal'));
    await tester.pumpAndSettle();
    expect(AuthService.preferredPaymentMethod, 'PayPal');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    for (final title in [
      'Program lojalnosti',
      'Obaveštenja',
      'Centar za pomoć',
    ]) {
      await tester.ensureVisible(find.text(title));
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, title), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(find.text('Odjavi se'));
    await tester.tap(find.text('Odjavi se'));
    await tester.pumpAndSettle();
    expect(find.text('Nastavi kao gost'), findsOneWidget);
    await tester.ensureVisible(find.text('Administratorska prijava'));
    await tester.tap(find.text('Administratorska prijava'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'admin');
    await tester.enterText(find.byType(TextFormField).at(1), 'admin123');
    await tester.tap(find.widgetWithText(FilledButton, 'Prijavi se'));
    await tester.pumpAndSettle();
    expect(find.text('Administracija'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Odjavi se'), 150);
    await tester.ensureVisible(find.text('Odjavi se'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Odjavi se'));
    await tester.pumpAndSettle();
    expect(find.text('Nastavi kao gost'), findsOneWidget);
  });
}
