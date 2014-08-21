class AddImagesRefToStats < ActiveRecord::Migration
  def change
    add_reference :stats, :image, index: true
  end
end
