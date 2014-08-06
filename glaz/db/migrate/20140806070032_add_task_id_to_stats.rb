class AddTaskIdToStats < ActiveRecord::Migration
  def change
    add_column :stats, :task_id, :integer
  end
end
