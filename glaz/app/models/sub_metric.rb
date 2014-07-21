class SubMetric < ActiveRecord::Base

    belongs_to :metric

    def metric 
        Metric.find(sub_metric_id)
    end    
end
