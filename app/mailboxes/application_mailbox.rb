class ApplicationMailbox < ActionMailbox::Base
  routing(all: :trip)
end
