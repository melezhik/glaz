class AddHandlerToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :handler, :binary, :size => 10.megabytes
  end
end
