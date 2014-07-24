class Xpoint < ActiveRecord::Base


    belongs_to :metric
    belongs_to :report

    def metric
        Metric.find metric_id
    end

    def report
        Report.find report_id
    end

end
