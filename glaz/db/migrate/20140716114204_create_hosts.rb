class CreateHosts < ActiveRecord::Migration
  def change
    create_table :hosts do |t|
      t.string :title
      t.string :fqdn

      t.timestamps
    end
  end
end
