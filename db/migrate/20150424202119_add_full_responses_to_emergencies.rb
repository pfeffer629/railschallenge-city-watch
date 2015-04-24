class AddFullResponsesToEmergencies < ActiveRecord::Migration
  def change
    add_column :emergencies, :full_response, :boolean, default: true
  end
end
