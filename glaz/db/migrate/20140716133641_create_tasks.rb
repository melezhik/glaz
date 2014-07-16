class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.belongs_to :host
      t.belongs_to :metric
    end
  end
end
