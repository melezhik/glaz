class AddTagIdToStats < ActiveRecord::Migration
  def change
    add_column :stats, :tag_id, :integer
  end
end
