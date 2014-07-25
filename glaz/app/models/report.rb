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

    def metrics_flat_list 
        list = []
        xpoints.each do |point|
            if point.metric.multi?
                point.metric.submetrics.each do |sm|
                    list << { :point => point , :metric => sm.obj, :multi => true, :group => point.metric.title, :group_metric => sm.metric }
                end
            else
                list << { :point => point , :metric => point.metric, :multi => false }
            end
        end
        list
    end

end
