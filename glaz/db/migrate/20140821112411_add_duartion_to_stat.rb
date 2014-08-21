class AddDuartionToStat < ActiveRecord::Migration
  def change
    add_column :stats, :duration, :integer
  end
end
