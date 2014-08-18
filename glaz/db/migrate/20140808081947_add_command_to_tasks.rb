class AddCommandToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :command, :text
  end
end
