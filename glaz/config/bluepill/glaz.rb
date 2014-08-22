 Bluepill.application("glaz") do |app|

      app.process("api") do |process|
        process.working_dir = "/home/glaz/projects/glaz/glaz"
        process.start_command = "bin/bundle exec rails server -d"
        process.pid_file = "/home/glaz/projects/glaz/glaz/tmp/pids/server.pid"
      end

 end
