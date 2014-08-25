class Image < ActiveRecord::Base

    belongs_to :report
    has_many :stats, :dependent => :destroy

    def has_stats?
        stats.size > 0
    end


    def data

         cur_host = nil
         j = 0 
         rows = []
         cols = []
    
         stats.each do  |i| 
        
            j += 1
            cur_host = i.host_id if j == 1

            # age = time_ago_in_words(Time.at(i[:timestamp])) 
            
             if i[:status] == 'DJ_OK' and  Time.at(i[:timestamp]) > 10.minutes.ago  and i[:deviated] == false 
                 css_class = 'success'  
                 status = 'ok'  
             elsif i[:status] == 'DJ_OK' and  Time.at(i[:timestamp]) <= 10.minutes.ago  and i[:deviated] == false 
                 css_class = 'warning' 
                 status = 'outdated'  
             elsif i[:status] == 'DJ_OK' and  Time.at(i[:timestamp]) > 10.minutes.ago  and i[:deviated] == true 
                 css_class = 'danger' 
                 status = 'deviated'  
             elsif i[:status].include? 'ERROR'  
                 css_class = 'danger' 
                 status = i[:status]  
             else  
                 css_class = 'info' 
                 status = i[:status]  
             end 
        
             if ( cur_host != i.host_id  ) 
                 cur_host = i.host_id;  rows << { :data =>  cols  , :fqdn => i.host.fqdn }
                 logger.info "#{cols.size} entries found for host #{i.host.fqdn}"
                 cols = [ [ i, "status: #{status}. default value: #{i.metric[:default_value]}. ", css_class ] ] 
             else    
                 cols << [ i, "status: #{status}. default value: #{i.metric[:default_value]}. ", css_class ] 
             end 

        end 

        rows << { :data =>  cols  , :fqdn => cols[0][0].host.fqdn } if rows.size == 0 and cols.size > 0

        logger.info "#{rows.size} entries found for image ID #{id}"

        rows

    end

end
