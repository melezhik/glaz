class Stat < ActiveRecord::Base

	validates :metric_id, presence: true
	validates :task_id, presence: true

	belongs_to :image
    has_many :logs, :dependent => :destroy

    def metric
        Metric.find metric_id
    end

    def host
        Host.find host_id
    end

    def has_logs?
        logs.size > 0
    end

    def deviated?
        deviated
    end

end
