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
	            rows << { :data =>  cols  , :fqdn => cols[0][0].host.fqdn, :name => cols[0][0].host.title } 
	            logger.info "add #{cols.size} stat entries to report for host #{cols[0][0].host.fqdn}. (last host, single host reports)"
        end
        
        logger.info "#{rows.size} entries found for image ID #{id}"

        rows

    end


    def data_as_json

        json = { :stat => [] , :report => {} }

        json[ :report ] = {
            :report_id => report.id,
            :title => report.title,
            :image_id => id,
            :updated_at => stats.max { | a, b| a[:updated_at] <=> b[:updated_at] }[:updated_at]
        }

        data.each do |h|

            hd = Hash.new
            json[:stat] << hd
            hd[:fqdn] = h[:fqdn]
            hd[:name] = h[:name]
            hd[:metrics] = Array.new
    
            h[:data].each do |m|
                 mt = Hash.new
                 hd[:metrics] << mt
                 mt[:name] = m[0].metric.name
                 mt[:title] = m[0].metric.title
                 mt[:attrs] = Hash.new
                 mt[:attrs][:deviated] = m[0][:deviated]
                 mt[:attrs][:duration] = m[0][:duration]
                 mt[:attrs][:title] = m[0].metric.title
                 mt[:attrs][:timestamp] = m[0][:timestamp]
                 mt[:attrs][:status] = m[0][:status]
                 mt[:attrs][:created_at] = m[0][:created_at]
                 mt[:attrs][:updated_at] = m[0][:updated_at]
                 mt[:attrs][:value] = m[0][:value]
                 mt[:attrs][:info] = m[1]
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
