class BuildAsync < Struct.new( :task   )


    def perform
        runner = RunTask.new task
        runner.run 
    end

    def before(job) 
        mark_build_as_in_progress
        log :debug, "scheduled async build for task ID: #{task.id}"
    end

    def after(job)
        log :debug, "finished async build for task ID: #{task.id}"
        build.update({ :duration => (build.updated_at - build.created_at).to_int })
        build.save!
        log :debug, "#{build.duration} seconds took for this build"
    end

    def success(job)
        log :debug, "succeeded async build for task ID: #{task.id}"
    end


    def error(job, ex)
        log  :error, "failed async build for task ID: #{task.id}"
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
        build.update({ :status => 'IN_PROGRESS' })
        build.save!
    end

    def mark_build_as_failed
        build.update({ :status => 'FAIL' })
        build.save!
    end

    def mark_build_as_succeeded
        build.update({ :status => 'OK' })
        build.save!
    end

end
