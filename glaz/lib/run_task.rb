require File.join(File.dirname(__FILE__),'errors')
require 'open3'

class RunTask < Struct.new( :host, :metric, :task, :build, :stat, :env, :build_async   )

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

        @retval = @data.join(" ")

        if task.has_handler?

            build_async.log :info, "metric's handler is being overriden by tasks's handler"
            handler = task.handler

            build_async.log :debug, "applying handler"
            build_async.log :ruby, "#{handler}"
            self.instance_eval handler
            build_async.log :info, "data returned ( after handler ) for #{metric.title}: #{@retval}"

        elsif metric.has_handler?

            build_async.log :info, "handler is taken as metric's handler"
            handler = metric.handler

            build_async.log :debug, "applying handler"
            build_async.log :ruby, "#{handler}"

            begin
                self.instance_eval handler

                build_async.log :info, "data returned ( after handler ) for #{metric.title}: #{@retval}"

                build.update!(:retval =>  "#{metric.title} : #{@retval}")
                build.save!

                stat.update( :value => @retval , :timestamp =>  Time.now.to_i, :status => 'OK' )
                stat.save!

                build_async.log :info, "update stat: #{metric.title} => #{stat.value}"

            rescue Exception => ex
                build_async.log :error, "handler execution failed. #{ex.class}: #{ex.message}"
                stat.update( :value => @retval , :timestamp =>  Time.now.to_i, :status => 'HANDLER_FAILED' )
                stat.save!
            end

        else

            build_async.log :debug, "no handler defined"

        end    


    end

private

    def execute_command(cmd, raise_ex = true)

        build_async.log :info, "running command: #{cmd}"

        chunk = ""
        retval = []

        Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|

            i = 0; chunk = []
            while line = stdout.gets
                i += 1
                chunk << line
                retval << line.chomp
                if chunk.size > 30
                    build_async.log :debug,  ( chunk.join "" ) if metric.verbose
                    chunk = []
                    retval << line.chomp
                end
            end

            # write first / last chunk
            unless chunk.empty?
                build_async.log :debug,  ( chunk.join "" ) if metric.verbose
            end

            i = 0; chunk = []
            while line = stderr.gets
                i += 1
                chunk << line
                if chunk.size > 30
                    build_async.log :error,  ( chunk.join "" )
                    chunk = []
                end
            end

            # write first / last chunk
            unless chunk.empty?
                build_async.log :error,  ( chunk.join "" )
            end
    
            exit_status = wait_thr.value
            unless exit_status.success?

            build_async.log :info, "command failed"
                stat.update( :timestamp =>  Time.now.to_i, :status => 'CMD_FAILED' )
                stat.save!
                raise "command #{cmd} failed" if raise_ex == true
            end

        end


        stat.update( :timestamp =>  Time.now.to_i, :status => 'CMD_SUCCEED' )
        stat.save!

        build_async.log :info, "command succeeded"

        retval

    end


    def notify subject, recipients = []
        build_async.log :info, "hit notification stage"
        if env[ :notify ]
            build_async.log :info, "send notification: <#{subject}>"
            cmd = "echo http://web3-tst5.webdev.x:3000/reports/#{tag.report.id}/view?tag_id=#{tag.id}  | mail -s '#{subject}' #{recipients.join ' '}"
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

