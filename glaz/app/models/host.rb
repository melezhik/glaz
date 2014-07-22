class Host < ActiveRecord::Base

    validates :fqdn, presence: true
    has_many :tasks
    has_many :metrics, through: :tasks


    def has_metrics?
        metrics.size != 0
    end

    def enabled?
        enabled == true
    end

    def disabled?
        enabled == false
    end

    def task metric_id
        tasks.select{|i| i[:metric_id] == metric_id}.first
    end

    def active_tasks 
        tasks.select{|i| i.enabled? }
    end


    def metric_value metric
        stat[metric.id]
    end



    def stat 

        if ( data.nil? or data.empty? )
            Hash.new
        else
            (JSON.parse!(data)).to_hash
        end

    end


end
