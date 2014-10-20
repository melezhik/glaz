class Task < ActiveRecord::Base

    belongs_to :host
    belongs_to :metric

    
    def enabled?
        enabled == true
    end

    def host
        Host.find host_id
    end

    def metric
        Metric.find metric_id
    end


    def has_fqdn?
        ! (fqdn.nil? or fqdn.empty?)
    end

    def has_command?
        ! (command.nil? or command.empty? )
    end

    def has_command_type?
        ! (command_type.nil? or command_type.empty? )
    end

    def has_handler?
        ! (handler.nil? or handler.empty? )
    end

end
