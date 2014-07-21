class SubMetric < ActiveRecord::Base

    belongs_to :metric

    def obj_by_id 
        Metric.find(id)
    end    
end
