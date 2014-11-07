class AddHandlerToReports < ActiveRecord::Migration
  def change
    add_column :reports, :handler, :blob
  end
end
