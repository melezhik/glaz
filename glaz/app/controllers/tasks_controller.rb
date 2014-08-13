class TasksController < ApplicationController

    load_and_authorize_resource param_method: :_params

    def destroy

        @task = Task.find(params[:id])

        if @task.has_builds?
            flash[:warn] = "task ID:#{params[:id]} has builds, so cannot be removed, remove all task builds first"
        else
            @task.destroy
            flash[:notice] = "task ID:#{params[:id]} has been successfully removed"
        end
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

        env = {}
        env[ :notify ] = ( params[ :notify ].nil? or params[ :notify ].empty? ) ? false : true
        env[ :rails_root ] = root_url


        if @task.metric.has_sub_metrics?
            logger.info "task has submetrics, running over them"
            @task.metric.submetrics.each do |sm|
                build = @task.builds.create :state => 'PENDING'
                build.save!
                Delayed::Job.enqueue( BuildAsync.new( @task.host, sm.obj, @task, build, nil, env ) )
                logger.info "host ID: #{@task.host.id}, build ID:#{build.id} has been successfully scheduled to synchronization queue"
            end
        else
            logger.info "task has single metric"
            build = @task.builds.create :state => 'PENDING'
            build.save!
            Delayed::Job.enqueue( BuildAsync.new( @task.host, @task.metric, @task, build, nil, env ) )
            logger.info "host ID: #{@task.host.id}, build ID:#{build.id} has been successfully scheduled to synchronization queue"
        end

        flash[:notice] = "task ID: #{@task.host.id} has been successfully scheduled to synchronization queue"
        redirect_to :back
    end

    def edit
        @task = Task.find(params[:id])
    end

    def update

        @task = Task.find(params[:id])

        if @task.update _params
            flash[:notice] = "task ID: #{@task.id} has been successfully updated"
            redirect_to @task.host
        else 
            flash[:alert] = "error has been occured when update task ID: #{@task.id}"
            render 'edit'
        end

    end

private


    def _params
        params.require(:task).permit(
                :fqdn, :enabled,
                :command, :command_type, :handler
        )
    end

end
