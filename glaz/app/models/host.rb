class Host < ActiveRecord::Base


    attr_accessor :parent_host

    validates :fqdn, presence: true

    has_many :subhosts

    has_many :tasks
    has_many :metrics, through: :tasks

    has_many :points
    has_many :reports, through: :points

    has_many :xpoints
    has_many :reports, through: :xpoints


    def has_parent_host?
        ! (parent_host.nil? )
    end

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

    def has_sub_hosts?
        subhosts.size > 0
    end

    def multi?
        has_sub_hosts?
    end

    def subhosts_ids
        subhosts.map {|i| i.sub_host_id }
    end

    def has_host? host
        subhosts_ids.include? host.id
    end

    def subhosts_list
        subhosts.map {|sh| sh.obj }
    end


    def metrics_flat_list

        list = []

        tlist = has_parent_host? ? parent_host.tasks : tasks

        tlist.each do |task|
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

    def fqdn_short
        a = fqdn.split '.'
        a.first
    end
end

