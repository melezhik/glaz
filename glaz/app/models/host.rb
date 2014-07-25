class Host < ActiveRecord::Base

    validates :fqdn, presence: true

    has_many :tasks
    has_many :metrics, through: :tasks

    has_many :points
    has_many :reports, through: :points

    has_many :xpoints
    has_many :reports, through: :xpoints


    def has_metrics?
        metrics.size != 0
    end

    def enabled?
        enabled == true
    end

    def disabled?
        enabled == false
    end

    def active_tasks 
        tasks.select{|i| i.enabled? }
    end

    def metric_value metric
        if stat.has_key? "#{metric.id}"
            stat["#{metric.id}"]['value']
        else
            nil
        end
    end

    def has_metric? metric
        if metric.multi?
            metric.submetrics_ids.map  { |i| metrics_ids.include?  i }.include?  true
        else
            metrics_ids.include? metric.id
        end
    end

    def metric_timestamp metric
        if stat.has_key? "#{metric.id}"
            Time.at(stat["#{metric.id}"]["timestamp"])
        else
            nil
        end
    end

    def metric_has_timestamp? metric
        stat.has_key? "#{metric.id}" and stat["#{metric.id}"].has_key? "timestamp"
    end


    def stat 

        if ( data.nil? or data.empty? )
            Hash.new
        else
            (JSON.parse!(data)).to_hash
        end

    end


    def metrics_flat_list
        list = []
        tasks.each do |task|
            if task.metric.multi?
                task.metric.submetrics.each do |sm|
                    list << { :task => task , :metric => sm.obj, :multi => true, :group => task.metric.title, :group_metric => sm.metric } 
                end
            else
                list << { :task => task , :metric => task.metric, :multi => false } 
            end
        end
        list
    end

    def metrics_ids
        list = []
        metrics_flat_list.each { |i| list << i[:metric].id }
        list
    end

end
