cwd = File.expand_path(File.join(File.dirname(__FILE__), %w[ ../ ../ ]))

app = :glaz

secret_key_base = 'c0e5e5e3cc5d279191580b5f1a7468d134084591228820c983b438af670051fcedf36ed83d56f4dccf63601ecabf203196a1a69bb47adfc19600f883d6f3b280'

Eye.config do
    logger "#{cwd}/log/eye.log"
end

Eye.application app do

  working_dir cwd
  stdall "#{cwd}/log/trash.log" # stdout,err logs for processes by default

    group 'dj' do
            
        chain grace: 5.seconds

        workers = 30
    
        (1 .. workers).each do |i|
    
            process "dj#{i}" do
    
                pid_file "tmp/pids/delayed_job.#{i}.pid" # pid_path will be expanded with the working_dir
                
                start_command "rake jobs:work"
    
                stop_signals [:INT, 30.seconds, :TERM, 10.seconds, :KILL]
        
                daemonize true
        
                stdall "#{cwd}/log/dj.eye.log"

                env 'SECRET_KEY_BASE'   => secret_key_base
                env 'RAILS_ENV'         => 'production'
                env 'http_proxy'        => 'http://squid.adriver.x:3128'
                env 'https_proxy'       => 'http://squid.adriver.x:3128'
                env 'HTTP_PROXY'        => 'http://squid.adriver.x:3128'
                env 'HTTPS_PROXY'       => 'http://squid.adriver.x:3128'
                env 'adriver_leadstat_pass' => 'TSwccpzFfvFvwFhe'
        
            end
        end
    end

    process :api do

        env 'RAILS_ENV' => 'production'
        env 'SECRET_KEY_BASE' => secret_key_base
        pid_file "tmp/pids/server.pid"

        #start_command "rails server -d -P #{cwd}/tmp/pids/server.pid -p 3002"
        start_command "puma -C config/puma_production.rb -d --pidfile #{cwd}/tmp/pids/server.pid"
        daemonize false
        start_timeout 20.seconds
        stdall "#{cwd}/log/api.eye.log"
    end

end

