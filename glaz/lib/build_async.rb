class BuildAsync < Struct.new( :host, :metric, :task, :stat, :env   )


    def perform

        stat.update( :status => 'DJ_PERFORM'  )
        stat.save!

        @runner = RunTask.new host, metric, task, stat, env, self
        @runner.run 

    end

    def before(job) 
        log :debug, "scheduled async stat ID: #{stat.id}. env: #{env}"
        stat.update( :status => 'DJ_BEFORE'  )
        stat.save!
    end

    def after(job)
        log :debug, "finished async stat ID: #{stat.id}"
        stat.update( :timestamp =>  Time.now.to_i, :duration => ( Time.now - stat.created_at ).to_i )
        stat.save!
        log :debug, "#{stat.duration} seconds took to evaluate this stat"
    end

    def success(job)
        log :debug, "succeeded async stat ID: #{stat.id}"
        stat.update( :status => 'DJ_OK'  )
        stat.save!
    end


    def error(job, ex)
        log  :error, "failed async stat ID: #{stat.id}"
        log  :error, "#{ex.class} : #{ex.message}"
        log  :error, ex.backtrace
        stat.update( :status => 'DJ_ERROR'  )
        stat.save!
        log  :info, 'start notify to report error'
        @runner.notify "failed to execute stat for metric: #{ex.class}", %w{ app@adriver.ru }
    end

    def failure(job)
    end

    def max_attempts
        return 1
    end

    def log level, data
        _log level, data, nil 
    end

    def short_log level, data
        _log level, 'only first 100 lines are shown, set metric verbosity to true to see all data ...', nil 
        _log level, data, 100
    end

private

    def _log level, data, limit

        return if env.has_key? :no_log and env[:no_log] == true

        chunk = []; i = 0;

        data.split(/\n/).each do |line|

            chunk << line; i += 1

            break if limit and i > limit 

            if chunk.size > 30
                log_entry = stat.logs.create!
                log_entry.update!( { :chunk => (chunk.join "\n"), :level => level.to_s } )
                log_entry.save!
                stat.save!
                chunk = []
            end

    
        end

        # write first / last chunk
        unless chunk.empty?
            log_entry = stat.logs.create!
            log_entry.update!( { :chunk => (chunk.join "\n"), :level => level.to_s } )
            log_entry.save!
            stat.save!
        end

    end
end
