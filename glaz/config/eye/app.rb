cwd = File.expand_path(File.join(File.dirname(__FILE__), %w[ ../ ../ ]))

app = :glaz

Eye.config do
    logger "#{cwd}/log/eye.log"
end

Eye.application app do

  working_dir cwd
  stdall "#{cwd}/log/trash.log" # stdout,err logs for processes by default

    group 'dj' do
            
        chain grace: 5.seconds
        workers = 4
    
        (1 .. workers).each do |i|
    
            process "dj#{i}" do
    
                pid_file "tmp/pids/delayed_job.#{i}.pid" # pid_path will be expanded with the working_dir
                
                start_command "rake jobs:work"
    
                stop_signals [:INT, 30.seconds, :TERM, 10.seconds, :KILL]
        
                daemonize true
        
                stdall "#{cwd}/log/dj.eye.log"

                env 'RAILS_ENV'  => 'development'
        
            end
        end
    end

    process :api do

        pid_file "tmp/pids/server.pid"
        env 'RAILS_ENV'  => 'development'
        #start_command "rails server -d -P #{cwd}/tmp/pids/server.pid -p 3002"
        start_command "puma -C config/puma.rb -d --pidfile #{cwd}/tmp/pids/server.pid"
        daemonize false
        start_timeout 30.seconds
        stdall "#{cwd}/log/api.eye.log"
    end

end

