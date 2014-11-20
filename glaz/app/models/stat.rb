class Stat < ActiveRecord::Base


    include ActionView::Helpers::DateHelper

	validates :metric_id, presence: true
	# validates :task_id, presence: true


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

    def calculated_at
        if timestamp.nil?
            time_ago_in_words(created_at, include_seconds: true) + ' ago '
        else
            time_ago_in_words(Time.at(timestamp), include_seconds: true) + ' ago '
        end
    end

end
