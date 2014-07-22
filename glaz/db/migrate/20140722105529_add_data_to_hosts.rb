class AddDataToHosts < ActiveRecord::Migration
  def change
    add_column :hosts, :data, :binary, :limit => 10.megabyte
  end
end
