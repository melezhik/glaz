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
