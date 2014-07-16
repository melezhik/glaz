class AddCommandTypeToMetrics < ActiveRecord::Migration
  def change
    add_column :metrics, :command_type, :string, :default => 'ssh'
  end
end
