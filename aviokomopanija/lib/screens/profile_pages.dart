import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'booking_screens.dart' show validatePhone;

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: children,
          ),
        ),
      ),
    ),
  );
}

class PersonalDetailsPage extends StatelessWidget {
  const PersonalDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser!;
    return _ProfileForm(
      title: 'Lični podaci',
      fields: [user['name']!, AuthService.phone],
      labels: const ['Ime i prezime', 'Broj telefona'],
      email: user['email'],
      onSave: (values) {
        AuthService.updatePersonalDetails(values[0], values[1]);
      },
    );
  }
}

class _ProfileForm extends StatefulWidget {
  const _ProfileForm({
    required this.title,
    required this.fields,
    required this.labels,
    required this.onSave,
    this.email,
  });

  final String title;
  final List<String> fields;
  final List<String> labels;
  final ValueChanged<List<String>> onSave;
  final String? email;

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  final _form = GlobalKey<FormState>();
  late final _values = List<String>.of(widget.fields);

  @override
  Widget build(BuildContext context) => ProfilePage(
    title: widget.title,
    children: [
      Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.email case final email?) ...[
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Imejl'),
                child: Text(email),
              ),
              const SizedBox(height: 16),
            ],
            for (var i = 0; i < _values.length; i++) ...[
              TextFormField(
                initialValue: _values[i],
                decoration: InputDecoration(labelText: widget.labels[i]),
                keyboardType: widget.email != null && i == 1
                    ? TextInputType.phone
                    : TextInputType.name,
                validator: (value) {
                  final text = value!.trim();
                  if (widget.email != null && i == 1) {
                    return text.isEmpty ? null : validatePhone(text);
                  }
                  if (text.isEmpty) {
                    return 'Unesite ${widget.labels[i].toLowerCase()}.';
                  }
                  return null;
                },
                onSaved: (value) => _values[i] = value!.trim(),
              ),
              const SizedBox(height: 16),
            ],
            FilledButton(
              onPressed: () {
                if (!_form.currentState!.validate()) return;
                _form.currentState!.save();
                widget.onSave(_values);
                Navigator.pop(context, true);
              },
              child: const Text('Sačuvaj'),
            ),
          ],
        ),
      ),
    ],
  );
}

class SavedPassengersPage extends StatefulWidget {
  const SavedPassengersPage({super.key});

  @override
  State<SavedPassengersPage> createState() => _SavedPassengersPageState();
}

class _SavedPassengersPageState extends State<SavedPassengersPage> {
  final _passengers = AuthService.savedPassengers;

  Future<void> _edit([int? index]) async {
    final passenger = index == null ? null : _passengers[index];
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _ProfileForm(
          title: index == null ? 'Dodaj putnika' : 'Izmeni putnika',
          fields: [passenger?['first'] ?? '', passenger?['last'] ?? ''],
          labels: const ['Ime', 'Prezime'],
          onSave: (values) {
            final entry = {'first': values[0], 'last': values[1]};
            if (index == null) {
              _passengers.add(entry);
            } else {
              _passengers[index] = entry;
            }
            AuthService.savePassengers(_passengers);
          },
        ),
      ),
    );
    if (mounted && saved == true) setState(() {});
  }

  Future<void> _remove(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ukloniti putnika?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Otkaži'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ukloni'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() => _passengers.removeAt(index));
    AuthService.savePassengers(_passengers);
  }

  @override
  Widget build(BuildContext context) => ProfilePage(
    title: 'Sačuvani putnici',
    children: [
      if (_passengers.isEmpty) const Text('Još nema sačuvanih putnika.'),
      for (var i = 0; i < _passengers.length; i++)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.person_outline),
          title: Text('${_passengers[i]['first']} ${_passengers[i]['last']}'),
          onTap: () => _edit(i),
          trailing: IconButton(
            tooltip: 'Ukloni putnika',
            onPressed: () => _remove(i),
            icon: const Icon(Icons.delete_outline),
          ),
        ),
      const SizedBox(height: 16),
      FilledButton.icon(
        onPressed: () => _edit(),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Dodaj putnika'),
      ),
    ],
  );
}

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  @override
  Widget build(BuildContext context) => ProfilePage(
    title: 'Načini plaćanja',
    children: [
      const Text('Izaberite podrazumevani način probnog plaćanja.'),
      const SizedBox(height: 12),
      RadioGroup<String>(
        groupValue: AuthService.preferredPaymentMethod,
        onChanged: (method) {
          if (method != null) {
            setState(() => AuthService.setPreferredPaymentMethod(method));
          }
        },
        child: Column(
          children: [
            for (final method in AuthService.paymentMethods)
              RadioListTile<String>(value: method, title: Text(method)),
          ],
        ),
      ),
    ],
  );
}

class LoyaltyPage extends StatefulWidget {
  const LoyaltyPage({super.key});

  @override
  State<LoyaltyPage> createState() => _LoyaltyPageState();
}

class _LoyaltyPageState extends State<LoyaltyPage> {
  @override
  Widget build(BuildContext context) => ProfilePage(
    title: 'Program lojalnosti',
    children: [
      const Text('Demonstraciono članstvo u programu AirVista.'),
      const SizedBox(height: 12),
      SwitchListTile(
        title: const Text('Članstvo'),
        subtitle: Text(AuthService.loyaltyMember ? 'Aktivno' : 'Neaktivno'),
        value: AuthService.loyaltyMember,
        onChanged: (member) {
          setState(() => AuthService.setLoyaltyMembership(member));
        },
      ),
    ],
  );
}

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) => const ProfilePage(
    title: 'Centar za pomoć',
    children: [
      ExpansionTile(
        title: Text('Gde mogu da nađem svoju rezervaciju?'),
        children: [
          ListTile(
            title: Text(
              'Otvorite karticu Putovanja i izaberite „Pregledaj rezervaciju“.',
            ),
          ),
        ],
      ),
      ExpansionTile(
        title: Text('Kako funkcioniše plaćanje?'),
        children: [
          ListTile(
            title: Text(
              'Plaćanje je probno i nema naplate. Koristite samo probne podatke.',
            ),
          ),
        ],
      ),
      ExpansionTile(
        title: Text('Kako da ponovo upotrebim podatke putnika?'),
        children: [
          ListTile(
            title: Text(
              'Dodajte ime i prezime u Sačuvane putnike, pa izaberite putnika prilikom rezervacije.',
            ),
          ),
        ],
      ),
    ],
  );
}
