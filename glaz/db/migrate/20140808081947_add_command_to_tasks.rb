class AddCommandToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :command, :string
  end
end
