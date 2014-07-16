class Metric < ActiveRecord::Base

    validates :title, presence: true
    validates :command, presence: true

    has_many :hosts
    has_many :metrics, through: :hosts

end
