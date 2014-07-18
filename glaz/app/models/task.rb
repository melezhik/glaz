class Task < ActiveRecord::Base

    belongs_to :host
    belongs_to :metric

    has_many :builds
    
    def enabled?
        enabled == true
    end

    def host
        Host.find host_id
    end

    def metric
        Metric.find metric_id
    end

end
