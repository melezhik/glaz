class AddHandlerToImages < ActiveRecord::Migration
  def change
    add_column :images, :handler, :blob
  end
end
