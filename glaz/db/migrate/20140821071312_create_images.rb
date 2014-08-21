class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.boolean :keep_me, :default => false
      t.references :report, index: true

      t.timestamps
    end
  end
end
