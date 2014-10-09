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
            cur_host = i.host if j == 1

             if i[:status] == 'DJ_OK' and  Time.at(i[:timestamp]) > 10.minutes.ago  and i[:deviated] == false 
                 css_class = 'success'  
                 status = 'ok'  
             elsif i[:status] == 'DJ_OK' and  Time.at(i[:timestamp]) <= 10.minutes.ago  and i[:deviated] == false 
                 css_class = 'warning' 
                 status = 'outdated'  
             elsif i[:status] == 'DJ_OK' and  i[:deviated] == true 
                 css_class = 'danger' 
                 status = 'deviated'  
             elsif i[:status].include? 'ERROR'  
                 css_class = 'danger' 
                 status = i[:status]  
             else  
                 css_class = 'info' 
                 status = i[:status]  
             end 
        
             logger.info "process report stat: metric:#{i.metric.title}. host:#{i.host.fqdn}. status: #{status}"

             if ( cur_host.id != i.host_id  ) 

		         rows << { :data =>  cols  , :fqdn => cur_host.fqdn }

                 logger.info "add #{cols.size} stat entries to report for host #{cur_host.fqdn}"

                 cols = [ [ i, "status: #{status}. default value: #{i.metric[:default_value]}. ", css_class ] ] 

                 cur_host = i.host 

             else    
                 cols << [ i, "status: #{status}. default value: #{i.metric[:default_value]}. ", css_class ] 
             end 

        end 

        if rows.size == 0 and cols.size > 0
	        # add stat for first host, for single host reports
	            rows << { :data =>  cols  , :fqdn => cols[0][0].host.fqdn } 
	            logger.info "add #{cols.size} stat entries to report for host #{cols[0][0].host.fqdn}. (first host, single host reports)"
        elsif rows.size > 0 and cols.size > 0
	        # add stat for last host for multi hosts reports
	            rows << { :data =>  cols  , :fqdn => cols[0][0].host.fqdn } 
	            logger.info "add #{cols.size} stat entries to report for host #{cols[0][0].host.fqdn}. (last host, single host reports)"
        end
        
        logger.info "#{rows.size} entries found for image ID #{id}"

        rows

    end

    def data_as_json
        json = {}

        # return { :size => data.size }

        data.each do |r|
            json[ r[:fqdn] ] = Hash.new
            r[:data].each do |m|
                json[ r[:fqdn] ][m[0].metric.name] = Hash.new
                json[ r[:fqdn] ][m[0].metric.name][:title] = m[0].metric.title 
                json[ r[:fqdn] ][m[0].metric.name][:timestamp] = m[0][:timestamp] 
                json[ r[:fqdn] ][m[0].metric.name][:status] = m[0][:status] 
                json[ r[:fqdn] ][m[0].metric.name][:created_at] = m[0][:created_at] 
                json[ r[:fqdn] ][m[0].metric.name][:updated_at] = m[0][:updated_at] 
                json[ r[:fqdn] ][m[0].metric.name][:deviated] = m[0][:deviated] 
                json[ r[:fqdn] ][m[0].metric.name][:value] = m[0][:value] 
                json[ r[:fqdn] ][m[0].metric.name][:title] = m[1] 
	            logger.info "add metric #{m[0].metric.name} host #{r[:fqdn]} to json"
            end
        end
    json
    end

end

=begin comment
mysql> desc stats;
+------------+--------------+------+-----+---------+----------------+
| Field      | Type         | Null | Key | Default | Extra          |
+------------+--------------+------+-----+---------+----------------+
| id         | int(11)      | NO   | PRI | NULL    | auto_increment |
| value      | mediumblob   | YES  |     | NULL    |                |
| metric_id  | int(11)      | YES  | MUL | NULL    |                |
| timestamp  | int(11)      | YES  |     | NULL    |                |
| host_id    | int(11)      | YES  |     | NULL    |                |
| created_at | datetime     | YES  |     | NULL    |                |
| updated_at | datetime     | YES  |     | NULL    |                |
| task_id    | int(11)      | YES  | MUL | NULL    |                |
| image_id   | int(11)      | YES  | MUL | NULL    |                |
| status     | varchar(255) | YES  |     | PENDING |                |
| deviated   | tinyint(1)   | YES  |     | 0       |                |
| duration   | int(11)      | YES  |     | NULL    |                |
+------------+--------------+------+-----+---------+----------------+
12 rows in set (0.00 sec)

=end comment
