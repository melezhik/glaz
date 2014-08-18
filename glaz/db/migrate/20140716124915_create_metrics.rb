class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.string :title
      t.text :command
      t.string :default_value

      t.timestamps
    end
  end
end
