class AddFqdnToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :fqdn, :string
  end
end
