class CreateSindices < ActiveRecord::Migration
  def change
    create_table :sindices do |t|
      t.integer :stat_id

      t.timestamps
    end
  end
end
