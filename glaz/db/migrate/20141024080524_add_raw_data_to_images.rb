class AddRawDataToImages < ActiveRecord::Migration
  def change
    add_column :images, :raw_data, :blob
  end
end
