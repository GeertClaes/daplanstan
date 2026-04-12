# Active Storage and ActionMailbox inherit from ActiveRecord::Base, not our
# ApplicationRecord, so they miss the before_create UUID generator we defined
# there. This initializer patches them to generate UUIDs on create.

ActiveSupport.on_load(:active_storage_blob) do
  before_create { self.id ||= SecureRandom.uuid }
end

ActiveSupport.on_load(:active_storage_attachment) do
  before_create { self.id ||= SecureRandom.uuid }
end

ActiveSupport.on_load(:active_storage_variant_record) do
  before_create { self.id ||= SecureRandom.uuid }
end

ActiveSupport.on_load(:action_mailbox_inbound_email) do
  before_create { self.id ||= SecureRandom.uuid }
end
