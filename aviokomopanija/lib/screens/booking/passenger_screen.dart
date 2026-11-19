part of '../booking_screens.dart';

class PassengerScreen extends StatefulWidget {
  final Booking b;
  const PassengerScreen({super.key, required this.b});
  @override
  State<PassengerScreen> createState() => _PassengerScreenState();
}

class _PassengerScreenState extends State<PassengerScreen> {
  final form = GlobalKey<FormState>();
  late final List<Map<String, String>> data;
  late final List<int> nameRevisions;
  final savedPassengers = AuthService.savedPassengers;
  @override
  void initState() {
    super.initState();
    nameRevisions = List.filled(widget.b.count, 0);
    data = List.generate(
      widget.b.count,
      (i) => i < widget.b.passengers.length
          ? Map.of(widget.b.passengers[i])
          : <String, String>{},
    );
  }

  String type(int i) => i < widget.b.adults
      ? 'Odrasla osoba'
      : i < widget.b.adults + widget.b.children
      ? 'Dete'
      : 'Beba';
  Widget field(
    int i,
    String label,
    String key, {
    String? hint,
    TextInputType? keyboard,
    String? Function(String)? validate,
  }) => spaced(
    labeledField(
      label,
      TextFormField(
        key: key == 'first' || key == 'last'
            ? ValueKey((i, key, nameRevisions[i]))
            : null,
        initialValue: data[i][key],
        decoration: InputDecoration(hintText: hint),
        keyboardType: keyboard,
        onSaved: (v) => data[i][key] = v!.trim(),
        validator: (v) => v == null || v.trim().isEmpty
            ? 'Unesite ${label.toLowerCase()}.'
            : validate?.call(v.trim()),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => BookingPage(
    b: widget.b,
    title: 'Podaci o putnicima',
    step: 3,
    bottom: action('Nastavi na izbor sedišta', () {
      if (form.currentState!.validate()) {
        form.currentState!.save();
        widget.b.passengers
          ..clear()
          ..addAll(data);
        widget.b.update();
        open(context, SeatsScreen(b: widget.b));
      }
    }),
    child: Form(
      key: form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          spaced(
            small(
              'Unesite podatke tačno kao u pasošu. Vrsta putnika izabrana je u pretrazi. Bebe putuju u krilu odrasle osobe.',
            ),
          ),
          for (int i = 0; i < data.length; i++)
            panel(
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Putnik ${i + 1}',
                    style: const TextStyle(
                      fontFamily: 'AirVistaSerif',
                      fontSize: 23,
                    ),
                  ),
                  spaced(small(type(i))),
                  if (savedPassengers.isNotEmpty)
                    PopupMenuButton<Map<String, String>>(
                      onSelected: (passenger) {
                        setState(() {
                          data[i]['first'] = passenger['first']!;
                          data[i]['last'] = passenger['last']!;
                          nameRevisions[i]++;
                        });
                      },
                      itemBuilder: (context) => [
                        for (final passenger in savedPassengers)
                          PopupMenuItem(
                            value: passenger,
                            child: Text(
                              '${passenger['first']} ${passenger['last']}',
                            ),
                          ),
                      ],
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Izaberi sačuvanog putnika'),
                      ),
                    ),
                  field(i, 'Ime', 'first', hint: 'Marko'),
                  field(i, 'Prezime', 'last', hint: 'Petrović'),
                  spaced(
                    FormField<String>(
                      validator: (_) {
                        final birth = DateTime.tryParse(
                          data[i]['birthIso'] ?? '',
                        );
                        if (birth == null) return 'Izaberite datum rođenja.';
                        final travel = widget.b.date;
                        var age = travel.year - birth.year;
                        if (travel.month < birth.month ||
                            (travel.month == birth.month &&
                                travel.day < birth.day)) {
                          age--;
                        }
                        if ((type(i) == 'Odrasla osoba' && age < 12) ||
                            (type(i) == 'Dete' && (age < 2 || age >= 12)) ||
                            (type(i) == 'Beba' && age >= 2)) {
                          return 'Uzrast ne odgovara vrsti putnika.';
                        }
                        return null;
                      },
                      builder: (state) => labeledField(
                        'Datum rođenja',
                        InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () async {
                            final now = DateTime.now();
                            final date = await showDatePicker(
                              context: context,
                              initialDate:
                                  DateTime.tryParse(
                                    data[i]['birthIso'] ?? '',
                                  ) ??
                                  DateTime(1995, 6, 15),
                              firstDate: DateTime(1920),
                              lastDate: now,
                              helpText: 'Datum rođenja',
                            );
                            if (date != null && mounted) {
                              setState(() {
                                data[i]['birth'] =
                                    '${date.day}.${date.month}.${date.year}.';
                                data[i]['birthIso'] = date.toIso8601String();
                              });
                              state.didChange(data[i]['birth']);
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              errorText: state.errorText,
                              suffixIcon: const Icon(
                                Icons.calendar_today_outlined,
                                size: 20,
                              ),
                            ),
                            child: Text(
                              data[i]['birth'] ?? 'Izaberite datum',
                              style: TextStyle(
                                fontSize: 14,
                                color: data[i]['birth'] == null ? muted : green,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  spaced(
                    labeledField(
                      'Državljanstvo',
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: data[i]['nationality'] ?? 'Srbija',
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.public_outlined,
                            size: 19,
                            color: green,
                          ),
                        ),
                        items:
                            [
                                  'Srbija',
                                  'Crna Gora',
                                  'Bosna i Hercegovina',
                                  'Hrvatska',
                                  'Severna Makedonija',
                                  'Italija',
                                  'Nemačka',
                                ]
                                .map(
                                  (v) => DropdownMenuItem(
                                    value: v,
                                    child: Text(v),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => data[i]['nationality'] = v!,
                        onSaved: (v) => data[i]['nationality'] = v!,
                      ),
                    ),
                  ),
                  field(
                    i,
                    'Broj pasoša',
                    'passport',
                    hint: '012345678',
                    validate: (v) => RegExp(r'^[a-zA-Z0-9]{6,12}$').hasMatch(v)
                        ? null
                        : 'Unesite 6–12 slova ili cifara.',
                  ),
                  if (i == 0) ...[
                    field(
                      i,
                      'Adresa elektronske pošte',
                      'email',
                      hint: 'marko.petrovic@primer.rs',
                      keyboard: TextInputType.emailAddress,
                      validate: (v) =>
                          RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v)
                          ? null
                          : 'Unesite ispravnu adresu.',
                    ),
                    field(
                      i,
                      'Broj telefona',
                      'phone',
                      hint: '064 123 4567',
                      keyboard: TextInputType.phone,
                      validate: validatePhone,
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    ),
  );
}
