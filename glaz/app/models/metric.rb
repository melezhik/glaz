class Metric < ActiveRecord::Base


    has_many :tasks
    has_many :hosts, through: :tasks

    has_many :submetrics

    def has_sub_metrics?
        submetrics.size > 0
    end

    def multi?
        has_sub_metrics?
    end

    def submetrics_ids
        submetrics.map {|i| i.sub_metric_id }
    end

    def has_metric? metric
        submetrics.map{ |i| i.sub_metric_id }.include? metric.id
    end


    def has_handler?

        if handler.nil? or handler.empty? 
            false
        else
            true
        end
	end	


end
