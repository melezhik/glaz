class Task < ActiveRecord::Base
      belongs_to :host
      belongs_to :metric
end
