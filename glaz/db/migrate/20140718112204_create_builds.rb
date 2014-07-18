class CreateBuilds < ActiveRecord::Migration
  def change
    create_table :builds do |t|
      t.string :state
      t.text :value
      t.references :task, index: true
      t.timestamps
    end
  end
end
