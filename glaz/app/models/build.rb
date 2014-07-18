class Build < ActiveRecord::Base

    belongs_to :task

    has_many :logs

end
