 Bluepill.application("glaz") do |app|

      app.process("api") do |process|
        process.working_dir = "/home/glaz/projects/glaz/glaz"
        process.start_command = "bin/bundle exec rails server -d"
        process.pid_file = "/home/glaz/projects/glaz/glaz/tmp/pids/server.pid"
      end

      workers = ENV['dj_num'] ?  ENV['dj_num'].to_int : 5  

      (0...workers).each do |i|
          app.process("delayed_job.#{i}") do |process|

                process.working_dir = "/home/glaz/projects/glaz/glaz"

                process.pid_file = "/home/glaz/projects/glaz/glaz/tmp/pids/delayed_job.#{i}.pid"
                process.start_command = "bin/delayed_job start -i #{i}"
                process.stop_command = "bin/delayed_job stop -i #{i}"

                process.group = "glaz"
                process.group = "delayed_job"

                process.start_grace_time    = 10.seconds
                process.stop_grace_time     = 10.seconds
                process.restart_grace_time  = 10.seconds
         
          end
     end

 end
