class TasksController < ApplicationController


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
        flash[:notice] = "task ID: #{params[:id]} has been successfully scheduled to synchronization queue"
        redirect_to :back
    end

end
