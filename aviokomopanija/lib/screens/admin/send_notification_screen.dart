import 'package:flutter/material.dart';

import '../../models/booking.dart';
import '../../services/notification_service.dart';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});
  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final form = GlobalKey<FormState>();
  final body = TextEditingController();
  final time = TextEditingController();
  String type = 'Specijalna ponuda';
  String flight = flights.first.number;
  @override
  void dispose() {
    body.dispose();
    time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Slanje obaveštenja')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Form(
          key: form,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: const InputDecoration(
                  labelText: 'Vrsta obaveštenja',
                ),
                items:
                    [
                          'Specijalna ponuda',
                          'Promena vremena leta',
                          'Let je otkazan',
                        ]
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                onChanged: (v) => setState(() => type = v!),
              ),
              const SizedBox(height: 16),
              if (type != 'Specijalna ponuda') ...[
                DropdownButtonFormField<String>(
                  initialValue: flight,
                  decoration: const InputDecoration(labelText: 'Let'),
                  items: flights
                      .map(
                        (f) => DropdownMenuItem(
                          value: f.number,
                          child: Text('${f.number} · ${f.airline}'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => flight = v!,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Poruka se šalje putnicima koji su rezervisali ovaj let.',
                ),
                const SizedBox(height: 16),
              ],
              if (type == 'Promena vremena leta') ...[
                TextFormField(
                  controller: time,
                  decoration: const InputDecoration(
                    labelText: 'Novo vreme polaska (HH:mm)',
                  ),
                  validator: (v) =>
                      RegExp(r'^([01]\d|2[0-3]):[0-5]\d$')
                          .hasMatch(v?.trim() ?? '')
                      ? null
                      : 'Unesite vreme u formatu HH:mm.',
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: body,
                maxLines: 4,
                maxLength: 1000,
                decoration: const InputDecoration(
                  labelText: 'Tekst obaveštenja',
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Unesite tekst obaveštenja.'
                    : null,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.send_outlined),
                label: const Text('Pošalji obaveštenje'),
                onPressed: () {
                  if (!form.currentState!.validate()) return;
                  final departure = type == 'Promena vremena leta'
                      ? time.text.trim()
                      : null;
                  final count = NotificationService.instance.send(
                    title: type,
                    body: departure == null
                        ? body.text.trim()
                        : 'Novo vreme polaska: $departure. ${body.text.trim()}',
                    flightNumber: type == 'Specijalna ponuda' ? null : flight,
                    departure: departure,
                    cancelled: type == 'Let je otkazan',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        count == 0
                            ? 'Nema primalaca za izabrani let.'
                            : 'Poslato obaveštenja: $count.',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
