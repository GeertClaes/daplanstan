class AddInvitedEmailToFellowTravelers < ActiveRecord::Migration[8.1]
  def change
    # Allow traveler_id to be null for pending invitations
    change_column_null :fellow_travelers, :traveler_id, true

    add_column :fellow_travelers, :invited_email, :string
    add_index  :fellow_travelers, [ :owner_id, :invited_email ], unique: true
  end
end
