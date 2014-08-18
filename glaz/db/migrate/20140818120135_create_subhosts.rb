class CreateSubhosts < ActiveRecord::Migration
  def change
    create_table :subhosts do |t|
      t.references :host, index: true
      t.sub_host_id :integer
      t.timestamps
    end
  end
end
