class Report < ActiveRecord::Base

    has_many :points
    has_many :hosts, through: :points

    has_many :xpoints
    has_many :metrics, through: :xpoints


    def has_hosts?
        hosts.size != 0
    end

    def has_metrics?
        metrics.size != 0
    end

    def point host_id
        points.select{|i| i[:host_id] == host_id}.first
    end

    def xpoint metric_id
        xpoints.select{|i| i[:metric_id] == metric_id}.first
    end

end
