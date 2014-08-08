class AddCommandTypeToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :command_type, :string
  end
end
