part of '../booking_screens.dart';

class PaymentScreen extends StatefulWidget {
  final Booking b;
  const PaymentScreen({super.key, required this.b});
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final form = GlobalKey<FormState>();
  bool accepted = false;
  String method = AuthService.preferredPaymentMethod;
  bool luhn(String input) {
    final v = input.replaceAll(' ', '');
    if (!RegExp(r'^\d{13,19}$').hasMatch(v)) return false;
    int sum = 0;
    bool doubleDigit = false;
    for (int i = v.length - 1; i >= 0; i--) {
      int n = int.parse(v[i]);
      if (doubleDigit) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      doubleDigit = !doubleDigit;
    }
    return sum % 10 == 0;
  }

  Widget input(
    String label,
    String? Function(String) validate, {
    TextInputType? keyboard,
    bool secret = false,
  }) => spaced(
    labeledField(
      label,
      TextFormField(
        decoration: const InputDecoration(),
        keyboardType: keyboard,
        obscureText: secret,
        validator: (v) => validate(v?.trim() ?? ''),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final b = widget.b;
    return BookingPage(
      b: b,
      title: 'Plaćanje',
      step: 6,
      bottom: action('Plati · ${b.total} €', () {
        if (!form.currentState!.validate()) return;
        if (!accepted) {
          message(context, 'Potvrdite demonstracionu rezervaciju.');
          return;
        }
        final bookingError = NotificationService.instance.validateBooking(b);
        if (bookingError != null) {
          message(context, bookingError);
          return;
        }
        b.reference ??=
            'AV${DateTime.now().microsecondsSinceEpoch.toRadixString(36).toUpperCase()}';
        NotificationService.instance.confirmBooking(b);
        b.update();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => ConfirmationScreen(b: b)),
          (route) => route.isFirst || route.settings.name == '/booking',
        );
      }),
      child: Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            panel(
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lock_outline, color: green),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Demonstraciono plaćanje\nNema naplate. Koristite isključivo probne podatke.',
                      style: TextStyle(color: green, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              'Izaberite način plaćanja',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            panel(
              Column(
                children: [
                  for (final entry
                      in AuthService.paymentMethods.asMap().entries) ...[
                    if (entry.key > 0) const SizedBox(height: 8),
                    Semantics(
                      selected: method == entry.value,
                      button: true,
                      child: Material(
                        color: method == entry.value
                            ? const Color(0xFFEEF4ED)
                            : const Color(0xFFFAFBF8),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => setState(() => method = entry.value),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: method == entry.value
                                    ? green
                                    : const Color(0xFFE7EBE3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  [
                                    Icons.credit_card_outlined,
                                    Icons.account_balance_wallet_outlined,
                                    Icons.apple,
                                    Icons.account_balance_wallet_outlined,
                                  ][entry.key],
                                  size: 22,
                                  color: green,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: green,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  method == entry.value
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  size: 20,
                                  color: method == entry.value ? green : muted,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (method == 'Platna kartica')
              panel(
                Column(
                  children: [
                    small('Probni broj: 4242 4242 4242 4242'),
                    const SizedBox(height: 12),
                    input(
                      'Broj kartice',
                      (v) => luhn(v)
                          ? null
                          : 'Unesite ispravan probni broj kartice.',
                      keyboard: TextInputType.number,
                    ),
                    input('Datum isteka (MM/GG)', (v) {
                      final match = RegExp(r'^(0[1-9]|1[0-2])/(\d{2})$')
                          .firstMatch(v);
                      if (match == null) return 'Koristite format MM/GG.';
                      final end = DateTime(
                        2000 + int.parse(match[2]!),
                        int.parse(match[1]!) + 1,
                      );
                      return end.isAfter(DateTime.now())
                          ? null
                          : 'Kartica je istekla.';
                    }, keyboard: TextInputType.datetime),
                    input(
                      'CVV sigurnosni kod',
                      (v) => RegExp(r'^\d{3,4}$').hasMatch(v)
                          ? null
                          : 'Unesite 3 ili 4 cifre.',
                      keyboard: TextInputType.number,
                      secret: true,
                    ),
                    input(
                      'Ime i prezime vlasnika kartice',
                      (v) => v.split(' ').where((s) => s.isNotEmpty).length >= 2
                          ? null
                          : 'Unesite ime i prezime.',
                    ),
                  ],
                ),
              )
            else
              panel(
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 19,
                      color: green,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$method je izabran',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: green,
                            ),
                          ),
                          const SizedBox(height: 4),
                          small(
                            'Probno plaćanje bez naplate. Nastavite dugmetom „Plati“.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            priceSummary(b),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: accepted,
              onChanged: (v) => setState(() => accepted = v!),
              title: const Text(
                'Razumem da je ovo demonstraciona rezervacija.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
