class Image < ActiveRecord::Base

    belongs_to :report
    has_many :stats, :dependent => :destroy

    def has_stats?
        stats.size > 0
    end
end
