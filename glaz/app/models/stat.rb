class Stat < ActiveRecord::Base

	validates :metric_id, presence: true
	validates :build_id, presence: true
	validates :task_id, presence: true
	belongs_to :host

end
