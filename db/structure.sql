CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE IF NOT EXISTS "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "active_storage_blobs" ("id" uuid NOT NULL PRIMARY KEY, "key" varchar NOT NULL, "filename" varchar NOT NULL, "content_type" varchar, "metadata" text, "service_name" varchar NOT NULL, "byte_size" bigint NOT NULL, "checksum" varchar, "created_at" datetime(6) NOT NULL);
CREATE UNIQUE INDEX "index_active_storage_blobs_on_key" ON "active_storage_blobs" ("key") /*application='Daplanstan'*/;
CREATE TABLE IF NOT EXISTS "active_storage_attachments" ("id" uuid NOT NULL PRIMARY KEY, "name" varchar NOT NULL, "record_type" varchar NOT NULL, "record_id" uuid NOT NULL, "blob_id" uuid NOT NULL, "created_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_c3b3935057"
FOREIGN KEY ("blob_id")
  REFERENCES "active_storage_blobs" ("id")
);
CREATE INDEX "index_active_storage_attachments_on_blob_id" ON "active_storage_attachments" ("blob_id") /*application='Daplanstan'*/;
CREATE UNIQUE INDEX "index_active_storage_attachments_uniqueness" ON "active_storage_attachments" ("record_type", "record_id", "name", "blob_id") /*application='Daplanstan'*/;
CREATE TABLE IF NOT EXISTS "active_storage_variant_records" ("id" uuid NOT NULL PRIMARY KEY, "blob_id" uuid NOT NULL, "variation_digest" varchar NOT NULL, CONSTRAINT "fk_rails_993965df05"
FOREIGN KEY ("blob_id")
  REFERENCES "active_storage_blobs" ("id")
);
CREATE UNIQUE INDEX "index_active_storage_variant_records_uniqueness" ON "active_storage_variant_records" ("blob_id", "variation_digest") /*application='Daplanstan'*/;
CREATE TABLE IF NOT EXISTS "action_mailbox_inbound_emails" ("id" uuid NOT NULL PRIMARY KEY, "status" integer DEFAULT 0 NOT NULL, "message_id" varchar NOT NULL, "message_checksum" varchar NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE UNIQUE INDEX "index_action_mailbox_inbound_emails_uniqueness" ON "action_mailbox_inbound_emails" ("message_id", "message_checksum") /*application='Daplanstan'*/;
CREATE TABLE IF NOT EXISTS "users" ("id" uuid NOT NULL PRIMARY KEY, "name" varchar NOT NULL, "email" varchar NOT NULL, "avatar_url" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "theme" varchar DEFAULT 'midnight' NOT NULL /*application='Daplanstan'*/);
CREATE UNIQUE INDEX "index_users_on_email" ON "users" ("email") /*application='Daplanstan'*/;
CREATE TABLE IF NOT EXISTS "user_identities" ("id" uuid NOT NULL PRIMARY KEY, "user_id" uuid NOT NULL, "provider" varchar NOT NULL, "provider_uid" varchar NOT NULL, "provider_email" varchar, "access_token" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_684b0e1ce0"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_user_identities_on_user_id" ON "user_identities" ("user_id") /*application='Daplanstan'*/;
CREATE UNIQUE INDEX "index_user_identities_on_provider_and_provider_uid" ON "user_identities" ("provider", "provider_uid") /*application='Daplanstan'*/;
CREATE TABLE IF NOT EXISTS "approved_senders" ("id" uuid NOT NULL PRIMARY KEY, "trip_id" uuid NOT NULL, "email" varchar NOT NULL, "display_name" varchar, "approved_by_id" uuid NOT NULL, "approved_at" datetime(6) NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_b5cb55a79b"
FOREIGN KEY ("trip_id")
  REFERENCES "trips" ("id")
, CONSTRAINT "fk_rails_9f2d7485ff"
FOREIGN KEY ("approved_by_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_approved_senders_on_trip_id" ON "approved_senders" ("trip_id") /*application='Daplanstan'*/;
CREATE INDEX "index_approved_senders_on_approved_by_id" ON "approved_senders" ("approved_by_id") /*application='Daplanstan'*/;
CREATE UNIQUE INDEX "index_approved_senders_on_trip_id_and_email" ON "approved_senders" ("trip_id", "email") /*application='Daplanstan'*/;
CREATE TABLE IF NOT EXISTS "inbox_items" ("id" uuid NOT NULL PRIMARY KEY, "trip_id" uuid NOT NULL, "from_email" varchar NOT NULL, "from_name" varchar, "subject" varchar, "raw_body" text, "attachments_json" text, "received_at" datetime(6) NOT NULL, "sender_status" varchar DEFAULT 'pending_approval', "parse_status" varchar DEFAULT 'unparsed', "parsed_type" varchar, "parsed_data_json" text, "review_status" varchar DEFAULT 'pending_review', "reviewed_by_id" uuid, "reviewed_at" datetime(6), "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "raw_html" text /*application='Daplanstan'*/, CONSTRAINT "fk_rails_047259e2c9"
FOREIGN KEY ("trip_id")
  REFERENCES "trips" ("id")
, CONSTRAINT "fk_rails_b0d8efd21e"
FOREIGN KEY ("reviewed_by_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_inbox_items_on_trip_id" ON "inbox_items" ("trip_id") /*application='Daplanstan'*/;
CREATE INDEX "index_inbox_items_on_reviewed_by_id" ON "inbox_items" ("reviewed_by_id") /*application='Daplanstan'*/;
CREATE INDEX "idx_on_trip_id_sender_status_review_status_a561bfc18c" ON "inbox_items" ("trip_id", "sender_status", "review_status") /*application='Daplanstan'*/;
CREATE TABLE IF NOT EXISTS "accounts" ("id" uuid NOT NULL PRIMARY KEY, "owner_id" uuid NOT NULL, "name" varchar NOT NULL, "subscription_status" varchar DEFAULT 'free' NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_37ced7af95"
FOREIGN KEY ("owner_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_accounts_on_owner_id" ON "accounts" ("owner_id") /*application='Daplanstan'*/;
CREATE TABLE IF NOT EXISTS "travelers" ("id" uuid NOT NULL PRIMARY KEY, "account_id" uuid NOT NULL, "user_id" uuid, "name" varchar NOT NULL, "email" varchar, "avatar_url" varchar, "invite_accepted_at" datetime(6), "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_e9554b3429"
FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("id")
, CONSTRAINT "fk_rails_f3e5914586"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_travelers_on_account_id" ON "travelers" ("account_id") /*application='Daplanstan'*/;
CREATE INDEX "index_travelers_on_user_id" ON "travelers" ("user_id") /*application='Daplanstan'*/;
CREATE UNIQUE INDEX "index_travelers_on_account_id_and_user_id" ON "travelers" ("account_id", "user_id") WHERE user_id IS NOT NULL /*application='Daplanstan'*/;
CREATE TABLE IF NOT EXISTS "trips" ("id"  NOT NULL PRIMARY KEY, "title" varchar NOT NULL, "description" text, "start_date" date NOT NULL, "end_date" date NOT NULL, "cover_image_url" varchar, "inbound_email" varchar NOT NULL, "created_by_id"  NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "account_id"  NOT NULL, CONSTRAINT "fk_rails_b5e85b446a"
FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("id")
, CONSTRAINT "fk_rails_45cc0c7a87"
FOREIGN KEY ("created_by_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_trips_on_created_by_id" ON "trips" ("created_by_id") /*application='Daplanstan'*/;
CREATE UNIQUE INDEX "index_trips_on_inbound_email" ON "trips" ("inbound_email") /*application='Daplanstan'*/;
CREATE INDEX "index_trips_on_account_id" ON "trips" ("account_id") /*application='Daplanstan'*/;
CREATE TABLE IF NOT EXISTS "trip_members" ("id"  NOT NULL PRIMARY KEY, "trip_id"  NOT NULL, "role" varchar DEFAULT 'viewer' NOT NULL, "joined_at" datetime(6), "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "traveler_id"  NOT NULL, CONSTRAINT "fk_rails_ea64d876a7"
FOREIGN KEY ("trip_id")
  REFERENCES "trips" ("id")
, CONSTRAINT "fk_rails_c37a4fea56"
FOREIGN KEY ("traveler_id")
  REFERENCES "travelers" ("id")
);
CREATE INDEX "index_trip_members_on_trip_id" ON "trip_members" ("trip_id") /*application='Daplanstan'*/;
CREATE INDEX "index_trip_members_on_traveler_id" ON "trip_members" ("traveler_id") /*application='Daplanstan'*/;
CREATE UNIQUE INDEX "index_trip_members_on_trip_id_and_traveler_id" ON "trip_members" ("trip_id", "traveler_id") /*application='Daplanstan'*/;
CREATE TABLE IF NOT EXISTS "invites" ("id" uuid NOT NULL PRIMARY KEY, "token" varchar NOT NULL, "email" varchar, "note" varchar, "created_by_id" uuid NOT NULL, "used_by_id" uuid, "used_at" datetime(6), "expires_at" datetime(6), "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_b52eeab183"
FOREIGN KEY ("created_by_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_e0ae83ee81"
FOREIGN KEY ("used_by_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_invites_on_created_by_id" ON "invites" ("created_by_id") /*application='Daplanstan'*/;
CREATE INDEX "index_invites_on_used_by_id" ON "invites" ("used_by_id") /*application='Daplanstan'*/;
CREATE UNIQUE INDEX "index_invites_on_token" ON "invites" ("token") /*application='Daplanstan'*/;
CREATE TABLE IF NOT EXISTS "trip_items" ("id" uuid NOT NULL PRIMARY KEY, "trip_id" uuid NOT NULL, "added_by_id" uuid NOT NULL, "inbox_item_id" uuid, "kind" varchar NOT NULL, "name" varchar NOT NULL, "status" varchar DEFAULT 'idea' NOT NULL, "notes" text, "starts_at" datetime(6), "ends_at" datetime(6), "address" varchar, "latitude" decimal(10,6), "longitude" decimal(10,6), "amount" decimal(10,2), "currency" varchar, "confirmation_ref" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_3dbcc92a4a"
FOREIGN KEY ("trip_id")
  REFERENCES "trips" ("id")
, CONSTRAINT "fk_rails_50694c0248"
FOREIGN KEY ("added_by_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_adb69120e9"
FOREIGN KEY ("inbox_item_id")
  REFERENCES "inbox_items" ("id")
);
CREATE INDEX "index_trip_items_on_trip_id" ON "trip_items" ("trip_id") /*application='Daplanstan'*/;
CREATE INDEX "index_trip_items_on_added_by_id" ON "trip_items" ("added_by_id") /*application='Daplanstan'*/;
CREATE INDEX "index_trip_items_on_inbox_item_id" ON "trip_items" ("inbox_item_id") /*application='Daplanstan'*/;
CREATE INDEX "index_trip_items_on_trip_id_and_starts_at" ON "trip_items" ("trip_id", "starts_at") /*application='Daplanstan'*/;
CREATE TABLE IF NOT EXISTS "expenses" ("id"  NOT NULL PRIMARY KEY, "trip_id"  NOT NULL, "amount" decimal(10,2) NOT NULL, "currency" varchar DEFAULT 'EUR' NOT NULL, "description" varchar NOT NULL, "category" varchar NOT NULL, "expense_date" date NOT NULL, "added_by_id"  NOT NULL, "source" varchar DEFAULT 'manual', "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "confirmed_at" datetime(6), "confirmed_by_id" varchar, "paid_by_traveler_id" , "trip_item_id" , "inbox_item_id" , CONSTRAINT "fk_rails_7b2e784a13"
FOREIGN KEY ("inbox_item_id")
  REFERENCES "inbox_items" ("id")
, CONSTRAINT "fk_rails_a33050b697"
FOREIGN KEY ("paid_by_traveler_id")
  REFERENCES "travelers" ("id")
, CONSTRAINT "fk_rails_e9789f82d8"
FOREIGN KEY ("trip_id")
  REFERENCES "trips" ("id")
, CONSTRAINT "fk_rails_8536b6f7c0"
FOREIGN KEY ("added_by_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_9e835c3e80"
FOREIGN KEY ("trip_item_id")
  REFERENCES "trip_items" ("id")
);
CREATE INDEX "index_expenses_on_trip_id" ON "expenses" ("trip_id") /*application='Daplanstan'*/;
CREATE INDEX "index_expenses_on_added_by_id" ON "expenses" ("added_by_id") /*application='Daplanstan'*/;
CREATE INDEX "index_expenses_on_paid_by_traveler_id" ON "expenses" ("paid_by_traveler_id") /*application='Daplanstan'*/;
CREATE INDEX "index_expenses_on_trip_item_id" ON "expenses" ("trip_item_id") /*application='Daplanstan'*/;
CREATE INDEX "index_expenses_on_inbox_item_id" ON "expenses" ("inbox_item_id") /*application='Daplanstan'*/;
CREATE TABLE IF NOT EXISTS "media_items" ("id"  NOT NULL PRIMARY KEY, "trip_id"  NOT NULL, "media_type" varchar NOT NULL, "caption" varchar, "taken_at" datetime(6), "latitude" decimal(10,6), "longitude" decimal(10,6), "uploaded_by_id"  NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_c74185777c"
FOREIGN KEY ("trip_id")
  REFERENCES "trips" ("id")
, CONSTRAINT "fk_rails_ec3979c206"
FOREIGN KEY ("uploaded_by_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_media_items_on_trip_id" ON "media_items" ("trip_id") /*application='Daplanstan'*/;
CREATE INDEX "index_media_items_on_uploaded_by_id" ON "media_items" ("uploaded_by_id") /*application='Daplanstan'*/;
CREATE INDEX "index_media_items_on_trip_id_and_taken_at" ON "media_items" ("trip_id", "taken_at") /*application='Daplanstan'*/;
INSERT INTO "schema_migrations" (version) VALUES
('20260411144752'),
('20260409000002'),
('20260409000001'),
('20260408155636'),
('20260408154406'),
('20260407000001'),
('20260405000001'),
('20260331070009'),
('20260330213249'),
('20260330213245'),
('20260330213238'),
('20260330213233'),
('20260330213229'),
('20260330213222'),
('20260330213217'),
('20260330201931'),
('20260330191640'),
('20260330083951'),
('20260329133748'),
('20260329130118'),
('20260329093311'),
('20260329092750'),
('20260328112022'),
('20260328112019'),
('20260328112016'),
('20260328112013'),
('20260328112010'),
('20260328112007'),
('20260328112004'),
('20260328112001'),
('20260328111958'),
('20260328111920'),
('20260328111917'),
('20260328111914'),
('20260328111902'),
('20260328111901'),
('0');

