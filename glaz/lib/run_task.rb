require File.join(File.dirname(__FILE__),'errors')
require 'open3'

class RunTask < Struct.new( :task, :build, :build_async   )

    def run
        if task.metric.has_sub_metrics?
            build_async.log :info, "task has submetrics, running over them"
            task.metric.submetrics.each do |sm|
                execute_command sm.obj.command
            end
        else
            build_async.log :info, "task has single metric"
            execute_command task.metric.command
        end
    end

private

    def execute_command(cmd, raise_ex = true)

        retval = false
        build_async.log :info, "running command: #{cmd}"

        chunk = ""

        Open3.popen2e(cmd) do |stdin, stdout_err, wait_thr|

            i = 0; chunk = []
            while line = stdout_err.gets
                i += 1
                chunk << line
                if chunk.size > 30
                    build_async.log :debug,  ( chunk.join "" )
                    chunk = []
                end
            end

            # write first / last chunk
            unless chunk.empty?
                build_async.log :debug,  ( chunk.join "" )
            end
    
            exit_status = wait_thr.value
            retval = exit_status.success?
            unless exit_status.success?

            build_async.log :info, "command failed"
                raise "command #{cmd} failed" if raise_ex == true
            end

        end

        build_async.log :info, "command succeeded"
        retval

    end

end

