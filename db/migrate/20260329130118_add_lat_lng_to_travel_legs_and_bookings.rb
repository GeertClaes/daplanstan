class AddLatLngToTravelLegsAndBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :travel_legs, :arrival_latitude,   :decimal, precision: 10, scale: 6
    add_column :travel_legs, :arrival_longitude,  :decimal, precision: 10, scale: 6
    add_column :bookings,    :latitude,            :decimal, precision: 10, scale: 6
    add_column :bookings,    :longitude,           :decimal, precision: 10, scale: 6
  end
end
