class AddIndexIdToStat < ActiveRecord::Migration
  def change
    add_column :stats, :index_id, :integer
  end
end
