class Report < ActiveRecord::Base

    has_many :points
    has_many :hosts, through: :points


    def has_hosts?
        hosts.size != 0
    end

    def point host_id
        points.select{|i| i[:host_id] == host_id}.first
    end

end
