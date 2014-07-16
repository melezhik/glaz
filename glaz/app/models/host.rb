class Host < ActiveRecord::Base
    validates :fqdn, presence: true
end
