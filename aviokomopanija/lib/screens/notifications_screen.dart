import 'dart:async';

import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import 'booking_screens.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});
  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  Timer? timer;
  @override
  void initState() {
    super.initState();
    NotificationService.instance.refreshReminders();
    timer = Timer.periodic(const Duration(minutes: 1), (_) {
      NotificationService.instance.refreshReminders();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: NotificationService.instance,
    builder: (context, _) => IconButton(
      tooltip: 'Obaveštenja',
      style: IconButton.styleFrom(backgroundColor: Colors.white),
      onPressed: () => open(context, const NotificationsScreen()),
      icon: Badge(
        key: const ValueKey('notification-badge'),
        isLabelVisible: NotificationService.instance.hasUnread,
        backgroundColor: const Color(0xFFE66B65),
        child: const Icon(Icons.notifications_none_rounded, color: green),
      ),
    ),
  );
}

String notificationTime(DateTime date) {
  final elapsed = DateTime.now().difference(date);
  if (elapsed.inMinutes < 1) return 'Upravo sada';
  if (elapsed.inHours < 1) return 'Pre ${elapsed.inMinutes} min';
  if (elapsed.inDays < 1) return 'Pre ${elapsed.inHours} h';
  if (elapsed.inDays == 1) return 'Juče';
  return 'Pre ${elapsed.inDays} dana';
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final service = NotificationService.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Obaveštenja')),
      body: ListenableBuilder(
        listenable: service,
        builder: (context, _) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: service.hasUnread ? service.markAllRead : null,
                    icon: const Icon(Icons.done_all),
                    label: const Text('Označi sve kao pročitano'),
                  ),
                ),
                if (service.items.isEmpty) ...[
                  const SizedBox(height: 80),
                  const Icon(
                    Icons.notifications_none_rounded,
                    size: 56,
                    color: muted,
                  ),
                  heading('Nemate obaveštenja'),
                  const Text(
                    'Ovde će se pojaviti potvrde rezervacija i novosti o vašim letovima.',
                  ),
                ],
                for (final item in service.items)
                  panel(
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFEDF3EC),
                        child: Icon(
                          item.booking == null
                              ? Icons.local_offer_outlined
                              : Icons.flight_takeoff,
                          color: green,
                        ),
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(
                          color: green,
                          fontWeight: item.isRead
                              ? FontWeight.w500
                              : FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text(item.body),
                          const SizedBox(height: 8),
                          small(notificationTime(item.createdAt)),
                        ],
                      ),
                      trailing: item.isRead
                          ? null
                          : Semantics(
                              label: 'Nepročitano',
                              child: Icon(Icons.circle, size: 8, color: green),
                            ),
                      onTap: () {
                        service.markRead(item);
                        if (item.booking != null) {
                          open(context, ReservationScreen(b: item.booking!));
                        } else {
                          showDialog<void>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(item.title),
                              content: Text(item.body),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Zatvori'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
