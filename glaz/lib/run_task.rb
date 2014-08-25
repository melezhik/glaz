require File.join(File.dirname(__FILE__),'errors')
require 'open3'

class RunTask < Struct.new( :host, :metric, :task, :stat, :env, :build_async   )

    def run

        stat.update( :timestamp =>  Time.now.to_i, :status => 'PROCESSING' )
        stat.save!

        if task.has_command?
            build_async.log :info, "metric's command <#{metric.command}> is being overriden by task's command: #{task.command}, command is taken as <#{task.command}>"
            command = task.command
        else
            build_async.log :info, "command is taken as metric's command: <#{metric.command}>"
            command = metric.command
        end    

        if task.has_command_type?
            build_async.log :info, "metric's command type  <#{metric.command_type}> is being overriden by task's command_type: #{task.command_type}, command_type is taken as <#{task.command_type}>"
            command_type = task.command_type
        else
            build_async.log :info, "command_type is taken as metric's command_type: <#{metric.command_type}>"
            command_type = metric.command_type
        end    

        if task.has_fqdn?
            build_async.log :info, "host's fqdn <#{host.fqdn}> is being overriden by tasks's fqdn: #{task.fqdn}, fqdn is taken as <#{task.fqdn}>"
            fqdn = task.fqdn
        else
            build_async.log :info, "fqdn is taken as host's fqdn: <#{host.fqdn}>"
            fqdn = host.fqdn
        end    

        build_async.log :info, "running #{command_type} command: #{command} for host: #{fqdn}"

        raise "empty command" if command.nil? or  metric.command.empty?

        if command_type == 'ssh'
	        build_async.log :info, "running command as ssh command"
            @data = execute_command "ssh -o 'StrictHostKeyChecking no'  #{fqdn} \"#{command}\""
        elsif command_type == 'shell'
	        build_async.log :info, "running command as shell command"
            @data = execute_command command.sub('%HOST%', fqdn)
        else
            raise "unknown command type: #{command_type}"
        end

        @retval = @data.join ""


        if metric.verbose?
            build_async.log :info, "data returned from command stdout:\n<#{@retval}>" 
        else
            build_async.short_log :info, "data returned from command stdout:\n<#{@retval}>" 
        end

        stat.update( :timestamp =>  Time.now.to_i, :status => 'CMD_OK' )
        stat.save!


        if task.has_handler?

            build_async.log :info, "metric's handler is being overriden by tasks's handler"
            handler = task.handler

            build_async.log :debug, "applying handler"
            build_async.log :ruby, "#{handler}"

            begin 

                self.instance_eval handler

                build_async.log :info, "data returned after handler: <#{@retval}>"

                stat.update( :value => @retval , :timestamp =>  Time.now.to_i, :status => 'HANDLER_OK' )
                stat.save!

            rescue Execption => ex

                build_async.log :error, "handler execution failed. #{ex.class}: #{ex.message}"
                raise "#{ex.class}: #{ex.message}"

            end


        elsif metric.has_handler?

            build_async.log :info, "handler is taken as metric's handler"
            handler = metric.handler

            build_async.log :debug, "applying handler"
            build_async.log :ruby, "#{handler}"

            begin

                self.instance_eval handler

                build_async.log :info, "data returned after handler: <#{@retval}>"

                stat.update( :value => @retval , :timestamp =>  Time.now.to_i, :status => 'HANDLER_OK' )
                stat.save!

        
            rescue Exception => ex

                build_async.log :error, "handler execution failed. #{ex.class}: #{ex.message}"
                raise "#{ex.class}: #{ex.message}"

            end

        else

            stat.update( :value => @retval , :timestamp =>  Time.now.to_i, :status => 'HANDLER_OK' )
            stat.save!

            build_async.log :debug, "no handler defined"

        end    


        if metric.default_value.nil? or metric.default_value.empty?
            stat.update( :deviated => false )
            stat.save!
            build_async.log :info, "return value is not deviated"
        else
            mv  = stat.value || 'NOT-SET'
            dv = metric.default_value
            if "#{mv.strip}" != "#{dv.strip}"
                stat.update( :deviated => true )
                stat.save!
                build_async.log :warn, "return value is no deviated"
            else
                stat.update( :deviated => false )
                stat.save!
                build_async.log :info, "return value is no deviated"
            end
        end

        build_async.log :info, "final data returned: <#{@retval}>"

    end

private

    def execute_command(cmd, raise_ex = true)

        build_async.log :info, "running command: #{cmd}"

        retval = []

        Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|

            while line = stdout.gets("\n")
                retval << line
            end

            while line = stderr.gets("\n")
                build_async.log :error,  line
            end

            exit_status = wait_thr.value


            if exit_status.success?
        
                build_async.log :debug, "command successfully executed, exit status: #{exit_status}"
                stat.update( :timestamp =>  Time.now.to_i, :status => 'CMD_OK' )
                stat.save!

            else

                build_async.log :error, "command unsuccessfully executed, exit status: #{exit_status}"
                raise "command unsuccessfully executed, exit status: #{exit_status}"

            end

        end

        retval

    end


    def notify subject, recipients = []
        build_async.log :info, "hit notification stage"
        if env[ :notify ]
            build_async.log :info, "send notification: <#{subject}>"
            cmd = "echo #{env[:image_url]}  | mail -s '#{subject}' #{recipients.join ' '}"
            if system(cmd) == true
                build_async.log :info, "succesffully executed cmd: #{cmd}"
            else
                build_async.log :error, "failed execute cmd: #{cmd}"
            end
        else
            build_async.log :info, "skip sending notification, because env[:notify]: #{env[:notify]}"
        end
    end

end

