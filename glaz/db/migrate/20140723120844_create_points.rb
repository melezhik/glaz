class CreatePoints < ActiveRecord::Migration
  def change
    create_table :points do |t|
      t.belongs_to :host
      t.belongs_to :report
    end
  end
end
