class Submetric < ActiveRecord::Base

    belongs_to :metric

    def obj
        Metric.find(sub_metric_id)
    end    
end
