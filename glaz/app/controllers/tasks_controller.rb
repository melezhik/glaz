class TasksController < ApplicationController

    load_and_authorize_resource param_method: :_params

    def destroy
        @task = Task.find(params[:id])
        @task.destroy
        flash[:notice] = "task ID:#{params[:id]} has been successfully removed"
        redirect_to :back
    end

    def enable
        @task = Task.find(params[:id])
        @task.update!  :enabled  => true 
        @task.save!
        flash[:notice] = "task ID:#{params[:id]} has been successfully enabled"
        redirect_to :back
    end

    def disable
        @task = Task.find(params[:id])
        @task.update!  :enabled  => false 
        @task.save!
        flash[:notice] = "task ID:#{params[:id]} has been successfully disabled"
        redirect_to :back
    end

    def synchronize

        @task = Task.find(params[:id])

        if @task.metric.has_sub_metrics?
            logger.info "task has submetrics, running over them"
            @task.metric.submetrics.each do |sm|
                build = @task.builds.create :state => 'PENDING'
                build.save!
                Delayed::Job.enqueue( BuildAsync.new( @task.host, sm.obj, @task, build ) )
                logger.info "host ID: #{@task.host.id}, build ID:#{build.id} has been successfully scheduled to synchronization queue"
            end
        else
            logger.info "task has single metric"
            build = @task.builds.create :state => 'PENDING'
            build.save!
            Delayed::Job.enqueue( BuildAsync.new( @task.host, @task.metric, @task, build ) )
            logger.info "host ID: #{@task.host.id}, build ID:#{build.id} has been successfully scheduled to synchronization queue"
        end

        flash[:notice] = "task ID: #{@task.host.id} has been successfully scheduled to synchronization queue"
        redirect_to :back
    end

end
