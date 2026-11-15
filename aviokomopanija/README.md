# AirVista

Flutter aplikacija za fakultetsku prezentaciju, sa interfejsom na srpskom jeziku (latinica).

Pokretanje iz ovog direktorijuma:

```
flutter pub get
flutter run
```

Na početnom ekranu izaberite „Nastavi kao gost“, ili koristite postojeću prijavu. Proces je: pretraga → dostupni letovi → detalji i tarifa → putnici → sedišta → dodaci → plaćanje → potvrda. Donja navigacija omogućava povratak na pretragu, putovanja i profil.

Pretraga ima sažeta polja za polazište i odredište, datum i putnike. Dodir na aerodrom otvara izbor grada; „Putnici i klasa“ otvara prozor sa brojačima i izborom klase. Izmene se primenjuju dugmetom „Potvrdi“, a „Otkaži“ zadržava prethodne vrednosti. Pregled novog ekrana nalazi se u `preview/pretraga.png`.

Pregled rezervacije otvara se na zasebnom ekranu, sa strelicom nazad, prečicom za početnu i stalno dostupnim dugmetom „Nazad na početnu“. Broj telefona prihvata bilo koju dužinu, sa ili bez pozivnog broja, uz razmake, crtice, zagrade ili kosu crtu.

Pretraga podržava aerodrome, zamenu rute, datume, do devet putnika, ograničenje broja beba prema broju odraslih i klasu putovanja. Rezultati podržavaju filtere, sortiranje i omiljene letove. Putnici imaju proveru obaveznih podataka, uzrasta na dan leta, pasoša, elektronske pošte i telefona. Izbor sedišta sprečava dvostruko zauzimanje.

Podaci o letovima i cenama su demonstracioni. Za povratno putovanje koristi se obrnuta ruta, ista vremena i ista tarifa; dodaci i izbor sedišta važe za odlazni let. Nema veze sa stvarnim rezervacionim sistemom ili naplatom. Probna kartica: `4242 4242 4242 4242`, budući datum isteka u formatu `MM/GG`, CVV `123`. Podaci kartice se ne čuvaju u rezervaciji. Ostali načini plaćanja simuliraju uspeh nakon potvrde korisnika.

Rezervacija i omiljeni letovi čuvaju se u memoriji do zatvaranja aplikacije. „Dodaj u kalendar“ izvozi odlazni let u standardni `.ics` format sa podsetnikom dva sata ranije: u pregledaču se preuzima datoteka, a na izvornim platformama čuva u privremenoj fascikli i prikazuje putanja. Direktan upis u sistemski kalendar nije integrisan.

Provera:

```
flutter analyze
flutter test
flutter build web
```

Fotografije se učitavaju lokalno iz `assets/images/`; internet nije potreban za proces rezervacije.
