 Bluepill.application("glaz") do |app|

      app.process("api") do |process|
        process.working_dir = "/home/glaz/projects/glaz/glaz"
        process.start_command = "bin/bundle exec rails server -d"
        process.pid_file = "/home/glaz/projects/glaz/glaz/tmp/pids/server.pid"
      end

    (0..1).each do |i|

        app.process("delayed_job.#{i}") do |process|
            process.working_dir = "/home/glaz/projects/glaz/glaz"
     
            process.start_grace_time    = 10.seconds
            process.stop_grace_time     = 10.seconds
            process.restart_grace_time  = 10.seconds
             
            process.start_command = "./bin/delayed_job start -i #{i}"
            process.stop_command  = "./bin/delayed_job stop -i #{i}"
     
            process.pid_file = "/home/glaz/projects/glaz/glaz/tmp/pids/delayed_job.#{i}.pid"
    
            process.group = 'dj'
        end
    end

 end
