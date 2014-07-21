class CreateSubMetrics < ActiveRecord::Migration
  def change
    create_table :submetrics do |t|
      t.integer :sub_metric_id
      t.references :metric, index: true
      t.timestamps
    end
  end
end
