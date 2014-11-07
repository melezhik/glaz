class AddImageTypeToImages < ActiveRecord::Migration
  def change
    add_column :images, :layout_type, :string, :default => 'table'
  end
end
