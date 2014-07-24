class CreateXpoints < ActiveRecord::Migration
  def change
    create_table :xpoints do |t|
      t.belongs_to :metric
      t.belongs_to :report
    end
  end
end
