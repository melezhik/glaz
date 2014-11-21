class AddReportIdToSindex < ActiveRecord::Migration
  def change
    add_column :sindices, :report_id, :integer
  end
end
