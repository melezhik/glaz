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
            stat["#{metric.id}"]['value'].empty? ? 'undef' : stat["#{metric.id}"]['value']
        else
            nil
        end
    end

    def metric_value_diviated? metric

        if metric.default_value.nil? or metric.default_value.empty?
            false
        else
            mv  = metric_value(metric) || 'NOT-SET'
            dv = metric.default_value
            mv != dv
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


    def metric_status metric
        return -1 unless    has_metric? metric
        return -2 if        metric_value_diviated? metric
        return -3 unless    metric_has_timestamp? metric
        return -4 if        metric_timestamp(metric) < 10.minutes.ago
        return  1
    end

    def metric_status_as_text metric
        a = { -1 => 'danger',  -2 => 'warning', -3 => 'warning', -4 => 'danger', 1 => 'success' }
        a[ metric_status(metric) ]
    end
end

