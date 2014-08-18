class Report < ActiveRecord::Base

    has_many :points
    has_many :hosts, through: :points

    has_many :xpoints
    has_many :metrics, through: :xpoints

    has_many :tags

    def has_hosts?
        hosts.size != 0
    end

    def has_metrics?
        metrics.size != 0
    end

    def has_tags?
        tags.size != 0
    end

    def hosts_list 
        list = []
        points.each do |point|
                if point.host.multi?
                    point.host.subhosts_list.each do |h|
                        h.parent_host = point.host
                        list << { :point => point , :host => h }
                    end
                else
                    list << { :point => point , :host => point.host }
                end
        end
        list
    end

    def has_host? host
        hosts.map {|i| i.id }.include? host.id
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


    def has_metric? metric
        if metric.multi?
            metric.submetrics_ids.map  { |i| metrics_ids.include?  i }.include?  true
        else
            metrics_ids.include? metric.id
        end
    end

    def metrics_ids
        list = []
        metrics_flat_list.each { |i| list << i[:metric].id }
        list
    end


end
