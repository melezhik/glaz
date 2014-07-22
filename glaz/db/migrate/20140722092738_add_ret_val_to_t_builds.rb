class AddRetValToTBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :retval, :string
  end
end
