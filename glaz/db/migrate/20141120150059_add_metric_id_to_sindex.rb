class AddMetricIdToSindex < ActiveRecord::Migration
  def change
    add_column :sindices, :metric_id, :integer
  end
end
