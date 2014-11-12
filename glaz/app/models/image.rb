class Image < ActiveRecord::Base


    belongs_to :report

    has_many :stats, :dependent => :destroy

    def has_stats?
        stats.size > 0
    end

    def outdated?

        created_at <= 10.seconds.ago
    end

    def has_handler?

        if handler.nil? or handler.empty? 
            false
        else
            true
        end

    end

    def data

         cur_host = nil
         j = 0 
         rows = []
         cols = []
    
         stats.each do  |i| 
        
            j += 1
            cur_host = i.host if j == 1

             if i[:status] == 'DJ_OK' and  Time.at(i[:updated_at]) > 10.minutes.ago  and i[:deviated] == false 
                 css_class = 'success'  
                 status = 'ok'  
             elsif i[:status] == 'DJ_OK' and  Time.at(i[:updated_at]) <= 10.minutes.ago  and i[:deviated] == false 
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
	            rows << { :data =>  cols  , :fqdn => cols[0][0].host.fqdn, :name => cols[0][0].host.title, :id =>  cols[0][0].host.id  } 
	            logger.info "add #{cols.size} stat entries to report for host #{cols[0][0].host.fqdn}. (first host, single host reports)"
        elsif rows.size > 0 and cols.size > 0
	        # add stat for last host for multi hosts reports
	            rows << { :data =>  cols  , :fqdn => cols[0][0].host.fqdn, :name => cols[0][0].host.title, :id =>  cols[0][0].host.id } 
	            logger.info "add #{cols.size} stat entries to report for host #{cols[0][0].host.fqdn}. (last host, single host reports)"
        end
        
        logger.info "#{rows.size} entries found for image ID #{id}"

        rows

    end


    def schema

        json = { :schema => [] , :report => {} }

        json[ :report ] = {
            :report_id => report.id,
            :title => report.title,
            :image_id => id
        }

        data.each do |h|

            hd = Hash.new
            json[:schema] << hd
            hd[:id]   = h[:id]
            hd[:fqdn] = h[:fqdn]
            hd[:metrics] = Array.new
    
            h[:data].each do |m|
                 mt = Hash.new
                 hd[:metrics] << mt
                 mt[:id] = m[0].metric.id
                 mt[:task_id] = m[0][:task_id]
                 mt[:name] = m[0].metric.title
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
