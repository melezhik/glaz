class AddStatRefToLogs < ActiveRecord::Migration
  def change
    add_reference :logs, :stat, index: true
  end
end
