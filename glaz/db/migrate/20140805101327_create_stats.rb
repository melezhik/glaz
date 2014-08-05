class CreateStats < ActiveRecord::Migration
  def change
    create_table :stats do |t|
      t.text :value
      t.integer :metric_id
      t.integer :timestamp
      t.references :host, index: true

      t.timestamps
    end
  end
end
