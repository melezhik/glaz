class AddReportTypeToReports < ActiveRecord::Migration
  def change
    add_column :reports, :layout_type, :string, :default => 'table'
  end
end
