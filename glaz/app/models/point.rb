class Point < ActiveRecord::Base

    belongs_to :host
    belongs_to :report

end
