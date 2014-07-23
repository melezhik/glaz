class Report < ActiveRecord::Base

    belongs_to :host
    belongs_to :report

    def host
        Host.find host_id
    end

    def report
        Report.find report_id
    end

end
