user = User.find_or_create_by!(email: "geert.wl.claes@gmail.com") do |u|
  u.name  = "Geert"
  u.admin = true
end

account = Account.find_or_create_by!(owner: user) do |a|
  a.name = user.name
end

traveler = Traveler.find_or_create_by!(account: account, user: user) do |t|
  t.name  = user.name
  t.email = user.email
end

trip = Trip.find_or_create_by!(title: "Puglia") do |t|
  t.description   = "10 days through Bari, Gargano, the Amalfi coast, Monopoli and Lecce"
  t.start_date    = Date.new(2026, 6, 14)
  t.end_date      = Date.new(2026, 6, 23)
  t.inbound_email = "puglia-#{SecureRandom.hex(4)}@#{ENV.fetch("TRIP_EMAIL_DOMAIN", "whats.yourdomain.com")}"
  t.created_by    = user
  t.account       = account
end

TripMember.find_or_create_by!(trip: trip, traveler: traveler) do |m|
  m.role      = :owner
  m.joined_at = Time.current
end

[
  { kind: "flight", status: "confirmed", name: "Ryanair Düsseldorf (Weeze) → Bari",   starts_at: "2026-06-14 09:35", ends_at: "2026-06-14 11:55", address: "Bari, Italy",                                              latitude: 41.1258, longitude: 16.8620, notes: nil },
  { kind: "car",    status: "confirmed", name: "Sicily By Car",                        starts_at: "2026-06-14 13:00", ends_at: "2026-06-23 13:00", address: "Bari Karol Wojtyla Airport",                             latitude: 41.1369, longitude: 16.7600, notes: "Car Group: DS 3 Crossback or similar. Pick-up and drop-off at Bari Karol Wojtyla Airport. Flight number FR7524 mentioned." },
  { kind: "stay",   status: "confirmed", name: "Margherita Apartment",                 starts_at: "2026-06-14 14:00", ends_at: "2026-06-15 09:00", address: "Via Francesco Crispi 73, 70123 Bari, Italy",             latitude: 41.1245, longitude: 16.8585, notes: "One-Bedroom Apartment for 2 adults. Free cancellation until 8 May 2026. Key pickup on location." },
  { kind: "do",     status: "idea",      name: "Bari Vecchia — old town walk",         starts_at: "2026-06-14 16:00", ends_at: nil,                address: "Bari Vecchia, 70122 Bari",                               latitude: nil,     longitude: nil,     notes: "Wander the whitewashed lanes, watch nonnas making fresh orecchiette by hand in doorways" },
  { kind: "do",     status: "idea",      name: "Basilica di San Nicola",               starts_at: "2026-06-14 17:00", ends_at: nil,                address: "Piazza San Nicola 1, 70122 Bari",                        latitude: nil,     longitude: nil,     notes: "Stunning Romanesque basilica, one of the most important in southern Italy. Free entry" },
  { kind: "eat",    status: "idea",      name: "Bari Vecchia Street Food",             starts_at: "2026-06-14 19:00", ends_at: nil,                address: "Via Arco Basso, Bari Vecchia, Bari",                     latitude: nil,     longitude: nil,     notes: "Grab focaccia barese and fried panzerotti in the old town — best eaten walking around" },
  { kind: "eat",    status: "idea",      name: "Ristorante Il Pescatore",              starts_at: "2026-06-14 20:30", ends_at: nil,                address: "Via Federico II di Svevia 6, Bari",                      latitude: nil,     longitude: nil,     notes: "Fresh catch of the day, right on the harbour. Book ahead in summer" },
  { kind: "do",     status: "idea",      name: "Pizzomunno Beach & Scialara Beach",    starts_at: "2026-06-15 09:00", ends_at: nil,                address: "Lungomare Enrico Mattei, Vieste",                        latitude: nil,     longitude: nil,     notes: "The iconic white monolith rock on the beach. Arrive early for parking in June" },
  { kind: "do",     status: "idea",      name: "Boat tour of the Gargano sea caves",   starts_at: "2026-06-15 10:00", ends_at: nil,                address: "Vieste harbour, 71019 Vieste",                           latitude: nil,     longitude: nil,     notes: "Half-day boat trip around the dramatic limestone cliffs and sea caves. Kids love it" },
  { kind: "do",     status: "idea",      name: "Foresta Umbra",                        starts_at: "2026-06-15 14:00", ends_at: nil,                address: "Foresta Umbra, Gargano National Park",                  latitude: nil,     longitude: nil,     notes: "Ancient beech forest in the heart of the Gargano. Cool shade on hot June days, deer spotting" },
  { kind: "stay",   status: "confirmed", name: "VIESTEROOMS",                          starts_at: "2026-06-15 16:00", ends_at: "2026-06-16 08:00", address: "Via Generale Carlo Alberto dalla Chiesa 6, 71019 Vieste, Italy", latitude: 41.8855, longitude: 16.1507, notes: "1 night, Large Double Room for 2 adults. Breakfast included. Free cancellation until 8 May 2026." },
  { kind: "eat",    status: "idea",      name: "Osteria del Centro",                   starts_at: "2026-06-15 19:30", ends_at: nil,                address: "Via Mafrolla 8, 71019 Vieste",                           latitude: nil,     longitude: nil,     notes: "Simple, no-frills Apulian cooking. Try the orecchiette with cime di rapa" },
  { kind: "eat",    status: "idea",      name: "Il Trabucco da Mimi",                  starts_at: "2026-06-15 21:00", ends_at: nil,                address: "Localita Punta San Francesco, Vieste",                  latitude: nil,     longitude: nil,     notes: "Dinner on a historic trabucco fishing platform over the sea — unique experience" },
  { kind: "stay",   status: "confirmed", name: "Virgilio's Garden",                    starts_at: "2026-06-16 14:00", ends_at: "2026-06-17 08:00", address: "Via Virgilio 49, 80053 Castellammare di Stabia, Italy",  latitude: 40.7011, longitude: 14.4880, notes: "1 night, Double or Twin Room with Private Bathroom. Breakfast included. Free cancellation until 28 April 2026." },
  { kind: "eat",    status: "idea",      name: "Pizzeria Da Michele",                  starts_at: "2026-06-16 20:00", ends_at: nil,                address: "Via Cesare Sersale 1, Naples",                           latitude: nil,     longitude: nil,     notes: "The most famous pizza in the world. Only marinara and margherita. Worth the detour" },
  { kind: "do",     status: "idea",      name: "Mount Vesuvius hike",                  starts_at: "2026-06-17 08:00", ends_at: nil,                address: "Via Vesuvio, 80056 Ercolano",                            latitude: nil,     longitude: nil,     notes: "Hike to the crater rim — about 30 min from the car park. Incredible views over the bay of Naples" },
  { kind: "do",     status: "confirmed", name: "Pompeii",                              starts_at: "2026-06-17 09:00", ends_at: nil,                address: "80045 Pompei, Metropolitan City of Naples, Italy",       latitude: 40.7517, longitude: 14.4906, notes: "Printed ticket" },
  { kind: "eat",    status: "idea",      name: "Ristorante Il Capitano",               starts_at: "2026-06-17 13:00", ends_at: nil,                address: "Via Marina 10, Castellammare di Stabia",                 latitude: nil,     longitude: nil,     notes: "Local favourite for seafood pasta with views over the bay" },
  { kind: "stay",   status: "confirmed", name: "Casa Rebecca",                         starts_at: "2026-06-17 14:30", ends_at: "2026-06-20 10:00", address: "Via Insanguine 9, 70043 Monopoli, Italy",                latitude: 40.9481, longitude: 17.2919, notes: "Apartment for 2 adults, 3 nights. Garage parking available 700m away at EUR 10/night. Free cancellation until 13 April 2026." },
  { kind: "do",     status: "confirmed", name: "Pompeii",                              starts_at: "2026-06-18 09:00", ends_at: nil,                address: "80045 Pompei, Metropolitan City of Naples, Italy",       latitude: 40.7517, longitude: 14.4906, notes: "Printed ticket" },
  { kind: "do",     status: "idea",      name: "Herculaneum (Ercolano)",               starts_at: "2026-06-18 10:00", ends_at: nil,                address: "Corso Resina 187, 80056 Ercolano",                       latitude: nil,     longitude: nil,     notes: "Better preserved than Pompeii and far less crowded. Half a day is plenty" },
  { kind: "do",     status: "idea",      name: "Monopoli old town & castle",           starts_at: "2026-06-18 17:00", ends_at: nil,                address: "Castello Carlo V, Monopoli",                            latitude: nil,     longitude: nil,     notes: "Compact whitewashed old town right on the sea. The castle sits dramatically on the water's edge" },
  { kind: "eat",    status: "idea",      name: "Trattoria Al Borghese",                starts_at: "2026-06-18 20:00", ends_at: nil,                address: "Via San Cosimo 3, Monopoli",                             latitude: nil,     longitude: nil,     notes: "Family-run, excellent burrata and grilled fish. Very popular — arrive early" },
  { kind: "do",     status: "idea",      name: "Alberobello — trulli villages",        starts_at: "2026-06-19 09:00", ends_at: nil,                address: "Piazza del Popolo, 70011 Alberobello",                   latitude: nil,     longitude: nil,     notes: "UNESCO trulli houses 30 min from Monopoli. Go in the morning before coach tours arrive" },
  { kind: "eat",    status: "idea",      name: "Osteria del Mare",                     starts_at: "2026-06-19 13:00", ends_at: nil,                address: "Piazza Garibaldi 6, Monopoli",                           latitude: nil,     longitude: nil,     notes: "Romantic outdoor terrace in the old port. Great for a long lunch" },
  { kind: "do",     status: "idea",      name: "Cala Porto beach",                     starts_at: "2026-06-20 08:30", ends_at: nil,                address: "Cala Porto, Monopoli",                                  latitude: nil,     longitude: nil,     notes: "Small rocky cove just outside the old town walls. Clear water, great for a morning swim" },
  { kind: "stay",   status: "confirmed", name: "Dimora Vico dei Nohi",                 starts_at: "2026-06-20 15:00", ends_at: "2026-06-23 10:00", address: "7 Vico dei Nohi, 73100 Lecce, Italy",                    latitude: 40.3484, longitude: 18.1708, notes: "3 nights, Double Room for 2 adults. Breakfast included. Free cancellation until 9 May 2026." },
  { kind: "do",     status: "idea",      name: "Lecce Cathedral & Piazza del Duomo",   starts_at: "2026-06-21 18:00", ends_at: nil,                address: "Piazza del Duomo, 73100 Lecce",                          latitude: nil,     longitude: nil,     notes: "The heart of Lecce — golden baroque architecture at its finest. Best at golden hour" },
  { kind: "eat",    status: "idea",      name: "Alle Due Corti",                       starts_at: "2026-06-21 20:00", ends_at: nil,                address: "Corte dei Giugni 1, Lecce",                              latitude: nil,     longitude: nil,     notes: "Lecce institution. Try the pitta di patate and the rustico leccese" },
  { kind: "do",     status: "idea",      name: "Otranto day trip",                     starts_at: "2026-06-22 09:00", ends_at: nil,                address: "Piazza Basilica, 73028 Otranto",                         latitude: nil,     longitude: nil,     notes: "Stunning walled port town 45 min from Lecce. Cathedral mosaic floor is extraordinary" },
  { kind: "do",     status: "idea",      name: "Roman Amphitheatre of Lecce",          starts_at: "2026-06-22 10:00", ends_at: nil,                address: "Piazza Sant'Oronzo, 73100 Lecce",                        latitude: nil,     longitude: nil,     notes: "2nd century AD amphitheatre right in the city centre. Free to view from the piazza" },
  { kind: "eat",    status: "idea",      name: "Cucina Casareccia",                    starts_at: "2026-06-22 13:00", ends_at: nil,                address: "Via Costadura 19, Lecce",                                latitude: nil,     longitude: nil,     notes: "Home cooking at its best — grandmother's recipes, no menu, just what she cooked that day" },
  { kind: "flight", status: "confirmed", name: "Ryanair Bari → Düsseldorf (Weeze)",   starts_at: "2026-06-23 16:30", ends_at: "2026-06-23 18:55", address: "Bari, Italy",                                            latitude: 41.1258, longitude: 16.8620, notes: nil }
].each do |attrs|
  TripItem.find_or_create_by!(trip: trip, name: attrs[:name], starts_at: attrs[:starts_at]) do |i|
    i.kind       = attrs[:kind]
    i.status     = attrs[:status]
    i.ends_at    = attrs[:ends_at]
    i.address    = attrs[:address]
    i.latitude   = attrs[:latitude]
    i.longitude  = attrs[:longitude]
    i.notes      = attrs[:notes]
    i.added_by   = user
  end
end

[
  { description: "Düsseldorf (Weeze) ⇄ Bari (Ryanair)", amount: 249.36, currency: "EUR", expense_date: "2026-05-11", category: "flight" },
  { description: "Sicily By Car",                         amount: 296.67, currency: "EUR", expense_date: "2026-05-11", category: "car"    },
  { description: "Margherita Apartment",                  amount:  90.39, currency: "EUR", expense_date: "2026-05-11", category: "stay"   },
  { description: "VIESTEROOMS",                           amount:  82.00, currency: "EUR", expense_date: "2026-05-12", category: "stay"   },
  { description: "Virgilio's Garden",                     amount:  75.00, currency: "EUR", expense_date: "2026-05-13", category: "stay"   },
  { description: "Casa Rebecca",                          amount: 272.25, currency: "EUR", expense_date: "2026-05-14", category: "stay"   },
  { description: "Pompeii",                               amount:  50.00, currency: "EUR", expense_date: "2026-05-14", category: "do"     },
  { description: "Dimora Vico dei Nohi",                  amount: 207.90, currency: "EUR", expense_date: "2026-05-17", category: "stay"   }
].each do |attrs|
  Expense.find_or_create_by!(trip: trip, description: attrs[:description]) do |e|
    e.amount       = attrs[:amount]
    e.currency     = attrs[:currency]
    e.expense_date = attrs[:expense_date]
    e.category     = attrs[:category]
    e.confirmed    = true
    e.paid_by      = traveler
  end
end

puts "Seeded: 1 user, 1 trip (Puglia, #{Trip.find_by(title: 'Puglia').trip_items.count} items, #{Trip.find_by(title: 'Puglia').expenses.count} expenses)"
