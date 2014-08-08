require File.join(File.dirname(__FILE__),'errors')
require 'open3'

class RunTask < Struct.new( :host, :metric, :task, :build, :build_async   )

    def run

        if task.has_fqdn?
            build_async.log :info, "host's <#{host.fqdn}> is being override by metric's fqdn: #{task.fqdn}, fqdn is taken as <#{task.fqdn}>"
            fqdn = task.fqdn
        else
            build_async.log :info, "fqdn is taken as host's fqdn: <#{host.fqdn}>"
            fqdn = host.fqdn
        end    


        build_async.log :info, "running #{metric.command_type} command: #{metric.command} for host: #{fqdn}"

        raise "empty command" if metric.command.nil? or  metric.command.empty?

        if metric.command_type == 'ssh'
	        build_async.log :info, "running command as ssh command"
            @data = execute_command "ssh -o 'StrictHostKeyChecking no'  #{fqdn} \"#{metric.command}\""
        elsif metric.command_type == 'shell'
	        build_async.log :info, "running command as shell command"
            @data = execute_command metric.command.sub('%HOST%', fqdn)
        end

        @retval = @data.join(" ")

        if metric.has_handler?
            build_async.log :debug, "applying metric handler"
            build_async.log :ruby, "#{metric.handler}"
            self.instance_eval metric.handler
            build_async.log :info, "data returned ( after handler ) for #{metric.title}: #{@retval}"
        else
            build_async.log :debug, "no handler defined for this metric"
        end


        build.update!(:retval =>  "#{metric.title} : #{@retval}")
        build.save!

        stat = host.stats.create( :value => @retval , :timestamp =>  Time.now.to_i, :metric_id => metric.id, :build_id => build.id, :task_id => task.id )
        stat.save!

        build_async.log :info, "update stat: #{metric.title} => #{stat.value}"
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
                raise "command #{cmd} failed" if raise_ex == true
            end

        end

        build_async.log :info, "command succeeded"

        retval

    end

end

