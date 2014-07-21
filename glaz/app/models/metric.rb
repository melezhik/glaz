class Metric < ActiveRecord::Base

    validates :title, presence: true

    has_many :hosts
    has_many :metrics, through: :hosts

    has_many :sub_metrics

    def has_sub_metrics?
        sub_metrics.size > 0
    end
end
