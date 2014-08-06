class AddVerboseToMetrics < ActiveRecord::Migration
  def change
    add_column :metrics, :verbose, :boolean, :default => false
  end
end
