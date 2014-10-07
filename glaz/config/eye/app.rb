cwd = File.expand_path(File.join(File.dirname(__FILE__), %w[ ../ ../ ]))
port = 3000
app = :glaz

Eye.config do
    logger "#{cwd}/log/eye.log"
end

Eye.application app do

  working_dir cwd
  stdall "#{cwd}/log/trash.log" # stdout,err logs for processes by default

    group 'dj' do
            
        chain grace: 5.seconds
        workers = (ENV['dj_workers']||'5').to_i
    
        (1 .. workers).each do |i|
    
            process "dj#{i}" do
    
                pid_file "tmp/pids/delayed_job.#{i}.pid" # pid_path will be expanded with the working_dir
                
                start_command "rake jobs:work"
    
        	    stop_signals [:INT, 30.seconds, :TERM, 10.seconds, :KILL]
        
                daemonize true
        
                stdall "#{cwd}/log/dj.eye.log"
                
                env 'http_proxy' => 'http://squid.adriver.x:3128'
                env 'https_proxy' => 'http://squid.adriver.x:3128'
                env 'HTTP_PROXY' => 'http://squid.adriver.x:3128'
                env 'HTTPS_PROXY' => 'http://squid.adriver.x:3128'
        
            end
        end
    end

    process :api do

        pid_file "tmp/pids/server.pid"
        # start_command "rails server -d -P #{cwd}/tmp/pids/server.pid -p #{port}"
        start_command "puma -C config/puma.rb -d --pidfile #{cwd}/tmp/pids/server.pid"
        daemonize false
        stdall "#{cwd}/log/api.eye.log"
    end

end
