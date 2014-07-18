class Build < ActiveRecord::Base

    belongs_to :task

    has_many :logs


    def has_logs?
        logs.size > 0
    end

end
