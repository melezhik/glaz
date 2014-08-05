class Stat < ActiveRecord::Base
	validates :metric_id, presence: true
	belongs_to :host
end
