class AddStatusToStat < ActiveRecord::Migration
  def change
    add_column :stats, :status, :string, :default => 'PENDING'
  end
end
