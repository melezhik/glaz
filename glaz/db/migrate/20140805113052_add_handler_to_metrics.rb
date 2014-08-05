class AddHandlerToMetrics < ActiveRecord::Migration
  def change
    add_column :metrics, :handler, :binary, :size => 10.megabytes
  end
end
