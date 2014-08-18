class Subhost < ActiveRecord::Base

    belongs_to :host

    def obj
        Host.find(sub_host_id)
    end

end
