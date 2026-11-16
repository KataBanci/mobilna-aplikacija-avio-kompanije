import 'package:flutter/material.dart';

import '../../models/booking.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import 'management_screens.dart';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});
  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final form = GlobalKey<FormState>();
  final fields = AdminFields({'title': '', 'body': ''});
  String type = 'Opšte obaveštenje', recipients = 'Svi korisnici';
  String? flight, email;
  @override
  void dispose() {
    fields.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AdminPage(
    title: 'Novo obaveštenje',
    child: Form(
      key: form,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          fields.field('title', 'Naslov obaveštenja'),
          DropdownButtonFormField<String>(
            initialValue: type,
            decoration: const InputDecoration(labelText: 'Vrsta obaveštenja'),
            items: [
              'Opšte obaveštenje',
              'Specijalna ponuda',
              'Promena vremena leta',
              'Otkazivanje leta',
              'Podsetnik za putovanje',
            ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => type = v!,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: recipients,
            decoration: const InputDecoration(labelText: 'Primaoci'),
            items: [
              'Svi korisnici',
              'Putnici određenog leta',
              'Određeni korisnik',
            ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => setState(() => recipients = v!),
          ),
          const SizedBox(height: 16),
          if (recipients == 'Putnici određenog leta') ...[
            DropdownButtonFormField<String>(
              initialValue: flight,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Izaberite let'),
              items: flights
                  .map(
                    (f) => DropdownMenuItem(
                      value: f.number,
                      child: Text(
                        '${f.number} · ${f.origin} → ${f.destination}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => flight = v,
              validator: (v) => v == null ? 'Izaberite let.' : null,
            ),
            const SizedBox(height: 16),
          ],
          if (recipients == 'Određeni korisnik') ...[
            DropdownButtonFormField<String>(
              initialValue: email,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Izaberite korisnika',
              ),
              items: AuthService.users
                  .where((u) => u['role'] == 'user')
                  .map(
                    (u) => DropdownMenuItem(
                      value: u['email'],
                      child: Text(
                        '${u['name']} · ${u['email']}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => email = v,
              validator: (v) => v == null ? 'Izaberite korisnika.' : null,
            ),
            const SizedBox(height: 16),
          ],
          fields.field('body', 'Tekst obaveštenja', lines: 5),
          FilledButton.icon(
            icon: const Icon(Icons.send_outlined),
            label: const Text('Pošalji obaveštenje'),
            onPressed: () {
              if (!form.currentState!.validate()) return;
              final count = NotificationService.instance.send(
                title: fields.value('title'),
                body: '[$type] ${fields.value('body')}',
                flightNumber: recipients == 'Putnici određenog leta'
                    ? flight
                    : null,
                recipientEmail: recipients == 'Određeni korisnik'
                    ? email
                    : null,
              );
              adminMessage(
                context,
                count == 0
                    ? 'Nema primalaca za izabranu grupu.'
                    : 'Poslato obaveštenja: $count.',
              );
            },
          ),
          const SizedBox(height: 28),
          const Text(
            'Poslata obaveštenja',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          ListenableBuilder(
            listenable: NotificationService.instance,
            builder: (context, _) => Column(
              children: [
                if (NotificationService.instance.sent.isEmpty)
                  const ListTile(title: Text('Još nema poslatih obaveštenja.')),
                for (final n in NotificationService.instance.sent.take(50))
                  ListTile(
                    title: Text(n.title),
                    subtitle: Text('${n.owner}\n${n.body}'),
                    trailing: Icon(n.isRead ? Icons.done_all : Icons.done),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
