class AddEnabledToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :enabled, :boolean, :default => true 
  end
end
