# DATA_MODEL.md

## Entity Relationship Summary

```
User
 ├── UserIdentity (OAuth providers)
 └── Account
      └── Traveler (optional User link — can be pending invite)
           └── TripMember (join) ──── Trip
                                       ├── TripItem  ← single model for all stops/legs/stays/ideas
                                       ├── Expense   ← linked to TripItem + InboxItem
                                       ├── MediaItem
                                       ├── ApprovedSender
                                       └── InboxItem (review queue)
                                            ├── TripItem (inbox_item_id)
                                            └── Expense  (inbox_item_id)

Invite (beta gating and trip invites, created_by User)
```

### Account/Traveler design

`User` represents an authentication identity (OAuth login). `Account` is created for each user and acts as their roster of travel companions. `Traveler` represents a person on the account — they may or may not have a linked `User` yet. When someone is invited by email, a `Traveler` is created with their email but no `user_id`. When they sign in via OAuth, `Traveler#accept!` links the user and marks them as joined.

### TripItem — single model for all trip content

`TripItem` replaces what was previously four separate models (`TravelLeg`, `Accommodation`, `Booking`, `ShortlistItem`). Every stop, leg, stay, booking, activity, or idea on a trip is a `TripItem` with a `kind` and `status`.

---

## Migrations

### accounts
```ruby
create_table :accounts, id: :uuid do |t|
  t.references :owner, null: false, foreign_key: { to_table: :users }, type: :uuid
  t.string :name, null: false
  t.timestamps
end
add_index :accounts, :owner_id, unique: true
```

### travelers
```ruby
create_table :travelers, id: :uuid do |t|
  t.references :account, null: false, foreign_key: true, type: :uuid
  t.references :user, foreign_key: true, type: :uuid   # null if pending
  t.string :email
  t.string :name, null: false
  t.string :avatar_url
  t.datetime :invite_accepted_at
  t.timestamps
end
add_index :travelers, [:account_id, :user_id], unique: true, where: "user_id IS NOT NULL"
```

### invites
```ruby
create_table :invites, id: :uuid do |t|
  t.string :token, null: false
  t.string :email
  t.references :created_by, null: false, foreign_key: { to_table: :users }, type: :uuid
  t.references :used_by, foreign_key: { to_table: :users }, type: :uuid
  t.datetime :expires_at
  t.datetime :used_at
  t.timestamps
end
add_index :invites, :token, unique: true
```

### users
```ruby
create_table :users, id: :uuid do |t|
  t.string :name, null: false
  t.string :email, null: false
  t.string :avatar_url
  t.timestamps
end
add_index :users, :email, unique: true
```

### user_identities
```ruby
create_table :user_identities, id: :uuid do |t|
  t.references :user, null: false, foreign_key: true, type: :uuid
  t.string :provider, null: false      # google, apple
  t.string :provider_uid, null: false  # OAuth subject ID
  t.string :provider_email
  t.string :access_token               # encrypted
  t.timestamps
end
add_index :user_identities, [:provider, :provider_uid], unique: true
```

### trips
```ruby
create_table :trips, id: :uuid do |t|
  t.references :account, null: false, foreign_key: true, type: :uuid
  t.string :title, null: false
  t.text :description
  t.date :start_date, null: false
  t.date :end_date, null: false
  t.string :cover_image_url
  t.string :status, default: "planning", null: false
  t.string :inbound_email, null: false
  t.decimal :budget_amount, precision: 10, scale: 2
  t.string :budget_currency, default: "EUR"
  t.references :created_by, null: false, foreign_key: { to_table: :users }, type: :uuid
  t.timestamps
end
add_index :trips, :inbound_email, unique: true
```

### trip_members
```ruby
create_table :trip_members, id: :uuid do |t|
  t.references :trip, null: false, foreign_key: true, type: :uuid
  t.references :traveler, null: false, foreign_key: true, type: :uuid
  t.string :role, null: false, default: "viewer"
  t.timestamp :joined_at
  t.timestamps
end
add_index :trip_members, [:trip_id, :traveler_id], unique: true
```

### trip_items
```ruby
create_table :trip_items, id: :uuid do |t|
  t.references :trip,       null: false, foreign_key: true, type: :uuid
  t.references :added_by,   null: false, foreign_key: { to_table: :users }, type: :uuid
  t.references :inbox_item, foreign_key: true, type: :uuid   # null if added manually
  t.string  :kind,   null: false  # stay, flight, train, ferry, car, activity, restaurant, shopping, other
  t.string  :name,   null: false
  t.string  :status, null: false, default: "idea"  # idea, confirmed
  t.text    :notes
  t.datetime :starts_at
  t.datetime :ends_at
  t.string  :address
  t.decimal :latitude,  precision: 10, scale: 6
  t.decimal :longitude, precision: 10, scale: 6
  t.decimal :amount,    precision: 10, scale: 2
  t.string  :currency
  t.string  :confirmation_ref
  t.timestamps
end
```

### media_items
```ruby
create_table :media_items, id: :uuid do |t|
  t.references :trip, null: false, foreign_key: true, type: :uuid
  t.string :media_type, null: false     # photo, video
  t.string :caption
  t.datetime :taken_at
  t.decimal :latitude, precision: 10, scale: 6
  t.decimal :longitude, precision: 10, scale: 6
  t.references :uploaded_by, null: false, foreign_key: { to_table: :users }, type: :uuid
  t.timestamps
end
add_index :media_items, [:trip_id, :taken_at]
```

### expenses
```ruby
create_table :expenses, id: :uuid do |t|
  t.references :trip,      null: false, foreign_key: true, type: :uuid
  t.references :trip_item, foreign_key: true, type: :uuid   # the item this expense covers
  t.references :inbox_item, foreign_key: true, type: :uuid  # originating email (if any)
  t.decimal :amount, precision: 10, scale: 2, null: false
  t.string :currency, null: false, default: "EUR"
  t.string :description, null: false
  t.string :category, null: false  # accommodation, food_drink, transport, activities, shopping, other
  t.date :expense_date, null: false
  t.references :paid_by,  null: false, foreign_key: { to_table: :travelers }, type: :uuid
  t.references :added_by, null: false, foreign_key: { to_table: :users }, type: :uuid
  t.string :source, default: "manual"  # manual, receipt_photo, booking
  t.datetime :confirmed_at
  t.references :confirmed_by, foreign_key: { to_table: :users }, type: :uuid
  t.timestamps
end
add_index :expenses, :trip_id
```

### approved_senders
```ruby
create_table :approved_senders, id: :uuid do |t|
  t.references :trip, null: false, foreign_key: true, type: :uuid
  t.string :email, null: false
  t.string :display_name
  t.references :approved_by, null: false, foreign_key: { to_table: :users }, type: :uuid
  t.timestamp :approved_at, null: false
  t.timestamps
end
add_index :approved_senders, [:trip_id, :email], unique: true
```

### inbox_items
```ruby
create_table :inbox_items, id: :uuid do |t|
  t.references :trip, null: false, foreign_key: true, type: :uuid
  t.string :from_email, null: false
  t.string :from_name
  t.string :subject
  t.text :raw_body
  t.text :attachments_json          # JSON array of attachment metadata
  t.datetime :received_at, null: false
  t.string :sender_status, default: "pending_approval"   # pending_approval, approved, rejected
  t.string :parse_status, default: "unparsed"            # unparsed, parsed, failed
  t.text :parsed_data_json                                # AI-extracted fields as JSON
  t.string :review_status, default: "pending_review"     # pending_review, confirmed, discarded
  t.references :reviewed_by, foreign_key: { to_table: :users }, type: :uuid
  t.datetime :reviewed_at
  t.timestamps
end
add_index :inbox_items, [:trip_id, :sender_status, :review_status]
```

---

## Model Enums

```ruby
# trip.rb
enum :status, { planning: "planning", active: "active", completed: "completed" }

# trip_member.rb
enum :role, { owner: "owner", planner: "planner", contributor: "contributor", viewer: "viewer" }

# trip_item.rb
enum :kind, { stay: "stay", flight: "flight", train: "train", ferry: "ferry", car: "car",
              activity: "activity", restaurant: "restaurant", shopping: "shopping", other: "other" }
enum :status, { idea: "idea", confirmed: "confirmed" }

# inbox_item.rb
enum :sender_status, { pending_approval: "pending_approval", approved: "approved", rejected: "rejected" }
enum :parse_status, { unparsed: "unparsed", parsed: "parsed", failed: "failed" }
enum :review_status, { pending_review: "pending_review", confirmed: "confirmed", discarded: "discarded" }

# expense.rb
enum :category, {
  accommodation: "accommodation",
  food_drink: "food_drink",
  transport: "transport",
  activities: "activities",
  shopping: "shopping",
  other: "other"
}
enum :source, { manual: "manual", receipt_photo: "receipt_photo", booking: "booking" }
```

---

## Key Model Methods

```ruby
# trip.rb
before_validation :generate_inbound_email, on: :create

def generate_inbound_email
  self.inbound_email ||= "#{title.parameterize}-#{SecureRandom.hex(4)}@#{ENV['TRIP_EMAIL_DOMAIN']}"
end

def pending_review_count
  inbox_items.pending_review.count
end

# inbox_item.rb
def parsed_data
  JSON.parse(parsed_data_json) if parsed_data_json.present?
end

def parsed_data=(hash)
  self.parsed_data_json = hash.to_json
end

# traveler.rb
def pending?
  user_id.nil?
end

def accept!(user)
  update!(user: user, invite_accepted_at: Time.current)
end

# trip_item.rb
def geocoded?
  latitude.present? && longitude.present?
end
```
