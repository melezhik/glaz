class Host < ActiveRecord::Base
    validates :fqdn, presence: true
    has_many :tasks
    has_many :metrics, through: :tasks


    def has_metrics?
        metrics.size != 0
    end
end
