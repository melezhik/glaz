class AddBuildIdToStats < ActiveRecord::Migration
  def change
    add_column :stats, :build_id, :integer
  end
end
