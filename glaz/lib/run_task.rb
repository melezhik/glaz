require File.join(File.dirname(__FILE__),'errors')
require 'open3'

class RunTask < Struct.new( :task, :build, :build_async   )

    def run
        if task.metric.has_sub_metrics?
            build_async.log :info, "task has submetrics, running over them"
            task.metric.submetrics.each do |sm|
                retval = execute_command sm.obj.command
                task.update!(:retval =>  retval.join(" "))
                task.save!
            end
        else
            build_async.log :info, "task has single metric"
            retval = execute_command task.metric.command
            task.update!(:retval => retval.join(" "))
            task.save!
        end
    end

private

    def execute_command(cmd, raise_ex = true)

        build_async.log :info, "running command: #{cmd}"

        chunk = ""
        ret_val = []

        Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|

            i = 0; chunk = []
            while line = stdout.gets
                i += 1
                chunk << line
                if chunk.size > 30
                    build_async.log :debug,  ( chunk.join "" )
                    chunk = []
                    retval << line.chomp
                end
            end

            # write first / last chunk
            unless chunk.empty?
                build_async.log :debug,  ( chunk.join "" )
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

