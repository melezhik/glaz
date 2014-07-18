class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.string :level
      t.binary :chunk, :limit => 10.megabyte
      t.references :build, index: true

      t.timestamps
    end
  end
end
