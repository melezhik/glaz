class AddHostIdToSindex < ActiveRecord::Migration
  def change
    add_column :sindices, :host_id, :integer
  end
end
