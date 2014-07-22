class AddRetValToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :retval, :string
  end
end
