class AddDeviatedToStats < ActiveRecord::Migration
  def change
    add_column :stats, :deviated, :boolean, :default => false
  end
end
