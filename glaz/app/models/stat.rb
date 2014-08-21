class Stat < ActiveRecord::Base

	validates :metric_id, presence: true
	validates :build_id, presence: true
	validates :task_id, presence: true

	belongs_to :image
    has_many :logs, :dependent => :destroy

    def metric
        Metric.find metric_id
    end

    def has_logs?
        logs.size > 0
    end

end
