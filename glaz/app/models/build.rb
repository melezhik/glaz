class Build < ActiveRecord::Base

    belongs_to :task

    has_many :logs, :dependent => :destroy

    def has_logs?
        logs.size > 0
    end

end
