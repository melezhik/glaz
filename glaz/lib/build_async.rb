class BuildAsync < Struct.new( :host, :metric, :task, :build, :stat, :env   )


    def perform

        stat.update( :timestamp =>  Time.now.to_i, :status => 'PERFORM'  )
        stat.save!

        runner = RunTask.new host, metric, task, build, stat, env, self
        runner.run 

    end

    def before(job) 
        mark_build_as_in_progress
        log :debug, "scheduled async build ID: #{build.id}. env: #{env}"
    end

    def after(job)
        log :debug, "finished async build ID: #{build.id}"
        build.update({ :duration => (build.updated_at - build.created_at).to_int })
        build.save!
        log :debug, "#{build.duration} seconds took for this build"
    end

    def success(job)
        log :debug, "succeeded async build ID: #{build.id}"
        mark_build_as_succeeded

    end


    def error(job, ex)
        log  :error, "failed async build ID: #{build.id}"
        log  :error, "#{ex.class} : #{ex.message}"
        log  :error, ex.backtrace
    end

    def failure(job)
        mark_build_as_failed
    end

    def max_attempts
        return 1
    end

    def log level, data
        log_entry = build.logs.create!
        log_entry.update!( { :chunk => data, :level => level.to_s } )
        log_entry.save!
        build.save!
    end

    def mark_build_as_in_progress
        build.update({ :state => 'IN_PROGRESS' })
        build.save!
    end

    def mark_build_as_failed
        build.update({ :state => 'FAIL' })
        build.save!
    end

    def mark_build_as_succeeded
        build.update({ :state => 'SUCCEEDED' })
        build.save!
    end

end
