class CreateSubhosts < ActiveRecord::Migration
  def change
    create_table :subhosts do |t|
      t.references :host, index: true
      t.integer :sub_host_id
      t.timestamps
    end
  end
end
