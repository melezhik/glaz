class BuildAsync < Struct.new( :host, :metric, :task, :stat, :env   )


    def perform

        stat.update( :timestamp =>  Time.now.to_i, :status => 'DJ_PERFORM'  )
        stat.save!

        runner = RunTask.new host, metric, task, stat, env, self
        runner.run 

    end

    def before(job) 
        log :debug, "scheduled async stat ID: #{stat.id}. env: #{env}"
        stat.update( :timestamp =>  Time.now.to_i, :status => 'DJ_BEFORE'  )
        stat.save!
    end

    def after(job)
        log :debug, "finished async stat ID: #{stat.id}"
        stat.update({ :duration => (stat.updated_at - stat.created_at).to_int })
        stat.save!
        log :debug, "#{stat.duration} seconds took for this stat"
    end

    def success(job)
        log :debug, "succeeded async stat ID: #{stat.id}"
        stat.update( :timestamp =>  Time.now.to_i, :status => 'DJ_OK'  )
        stat.save!
    end


    def error(job, ex)
        log  :error, "failed async stat ID: #{stat.id}"
        log  :error, "#{ex.class} : #{ex.message}"
        log  :error, ex.backtrace
        stat.update( :timestamp =>  Time.now.to_i, :status => 'DJ_ERROR'  )
        stat.save!
    end

    def failure(job)
    end

    def max_attempts
        return 1
    end

    def log level, data


        chunk = []

        data.split("\n").each do |line|

            chunk << line

            if chunk.size > 30
                log_entry = stat.logs.create!
                log_entry.update!( { :chunk => (chunk.join ""), :level => level.to_s } )
                log_entry.save!
                stat.save!
                chunk = []
            end
        end

        # write first / last chunk
        unless chunk.empty?
            log_entry = stat.logs.create!
            log_entry.update!( { :chunk => (chunk.join ""), :level => level.to_s } )
            log_entry.save!
            stat.save!
        end

    end

end
