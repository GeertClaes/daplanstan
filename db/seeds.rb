user = User.find_or_create_by!(email: "geert.wl.claes@gmail.com") do |u|
  u.name = "Geert"
end

# Create account for the user
account = Account.find_or_create_by!(owner: user) do |a|
  a.name = user.name
end

# Create traveler profile for the owner in their own account
traveler = Traveler.find_or_create_by!(account: account, user: user) do |t|
  t.name      = user.name
  t.email     = user.email
end

trip = Trip.find_or_create_by!(title: "Puglia 2025") do |t|
  t.description   = "Two weeks in the heel of Italy"
  t.start_date    = Date.new(2025, 9, 1)
  t.end_date      = Date.new(2025, 9, 14)
  t.inbound_email = "puglia2025-seed@#{ENV.fetch("TRIP_EMAIL_DOMAIN", "whats.example.com")}"
  t.created_by    = user
  t.account       = account
end

TripMember.find_or_create_by!(trip: trip, traveler: traveler) do |m|
  m.role      = :owner
  m.joined_at = Time.current
end

[
  { kind: "stay",   name: "Masseria Torre Coccaro",        starts_at: DateTime.new(2025, 9, 1, 15, 0),  ends_at: DateTime.new(2025, 9, 7, 11, 0),  address: "Contrada Coccaro 8, Fasano, Italy", latitude: 40.8427, longitude: 17.3720, status: "confirmed" },
  { kind: "flight", name: "BRU \u2192 BRI Ryanair FR3421", starts_at: DateTime.new(2025, 9, 1, 7, 30),  ends_at: DateTime.new(2025, 9, 1, 10, 45), address: nil,                                latitude: 41.1395, longitude: 16.7623, status: "confirmed" },
  { kind: "eat",    name: "Ristorante Il Poeta Contadino", starts_at: DateTime.new(2025, 9, 3, 20, 0),  ends_at: nil,                               address: "Via Indipendenza 21, Alberobello",  latitude: 40.7806, longitude: 17.2394, status: "idea" }
].each do |attrs|
  TripItem.find_or_create_by!(trip: trip, name: attrs[:name]) do |i|
    i.kind        = attrs[:kind]
    i.status      = attrs[:status]
    i.starts_at   = attrs[:starts_at]
    i.ends_at     = attrs[:ends_at]
    i.address     = attrs[:address]
    i.latitude    = attrs[:latitude]
    i.longitude   = attrs[:longitude]
    i.added_by    = user
  end
end

puts "Seeded: 1 user, 1 account, 1 traveler, 1 trip, 3 trip items"
