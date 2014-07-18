class Task < ActiveRecord::Base
      belongs_to :host
      belongs_to :metric

    def enabled?
        enabled == true
    end

end
