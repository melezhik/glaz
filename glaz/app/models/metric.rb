class Metric < ActiveRecord::Base

    validates :title, presence: true

    has_many :hosts
    has_many :metrics, through: :hosts

    has_many :submetrics

    def has_sub_metrics?
        submetrics.size > 0
    end

    def multi?
        has_sub_metrics?
    end
end
