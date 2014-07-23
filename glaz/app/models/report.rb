class Report < ActiveRecord::Base

    has_many :points
    has_many :hosts, through: :points

    def host
        Host.find host_id
    end

    def report
        Report.find report_id
    end

end
