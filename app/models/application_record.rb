class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  before_create do
    self.id ||= SecureRandom.uuid
  end
end
