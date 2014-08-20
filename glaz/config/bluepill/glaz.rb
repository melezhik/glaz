 Bluepill.application("glaz") do |app|

      app.process("glaz-api") do |process|
        process.working_dir = "/home/glaz/projects/glaz/glaz"
        process.start_command = "bin/bundle exec unicorn_rails  -p 3000 -c config/unicorn.rb -D config.ru"
        process.pid_file = "/home/glaz/projects/glaz/glaz/tmp/pids/unicorn.pid"
      end

      app.process("glaz-delayed-job") do |process|
        process.working_dir = "/home/glaz/projects/glaz/glaz"
        process.start_command = "bin/delayed_job start -n 5"
        process.stop_command = "bin/delayed_job stop"
      end

 end
