class AddRetValToTBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :retval, :binary, :limit => 10.megabytes
  end
end
