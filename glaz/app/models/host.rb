class Host < ActiveRecord::Base

    validates :fqdn, presence: true

    has_many :stats

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

    def metric_stat metric, tag_id = nil
    	stats.where(' metric_id = ? ', metric.id ).order( "id DESC"  ).limit(1).first
    end
	
    def metric_value metric, tag_id = nil
	    stat = metric_stat metric
	    if stat		
	        (stat.value.nil? || stat.value.empty?) ? 'nil' : stat.value.force_encoding('UTF-8')
	    else
		    nil
	    end
    end

    def metric_build metric, tag_id = nil
	    stat = metric_stat metric
	    if stat		
	        Build.find stat.build_id
	    else
		    nil
	    end
    end

    def metric_task metric, tag_id = nil
	    stat = metric_stat metric
	    if stat		
	        Task.find stat.task_id
	    else
		    nil
	    end
    end

    def metric_value_diviated? metric, tag_id = nil

        if metric.default_value.nil? or metric.default_value.empty?
            false
        else
            mv  = metric_value(metric, tag_id) || 'NOT-SET'
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

    def metric_timestamp metric, tag_id = nil
	    stat = metric_stat metric		
        Time.at stat.timestamp
    end

    def metric_has_timestamp? metric, tag_id = nil
    	metric_stat metric		
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


    def metric_status metric, tag_id = nil
        return -1 unless    has_metric? metric
        return -3 unless    metric_has_timestamp? metric, tag_id
        return -2 if        metric_value_diviated? metric, tag_id
        return -4 if        metric_timestamp(metric, tag_id) < 10.minutes.ago
        return  1
    end

    def metric_status_as_color metric, tag_id = nil
        a = { -1 => 'Thistle',  -2 => 'Red', -3 => 'PowderBlue', -4 => 'Wheat', 1 => 'Green' }
        a[ metric_status(metric, tag_id) ]
    end

    def metric_status_as_text metric, tag_id = nil
        a = { -1 => 'unknown metric',  -2 => 'deviated', -3 => 'has never been successfully cacluated', -4 => 'outdated', 1 => 'ok' }
        a[ metric_status(metric, tag_id ) ]
    end

    	
end

