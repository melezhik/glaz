class Metric < ActiveRecord::Base
    validates :title, presence: true
    validates :command, presence: true
end
