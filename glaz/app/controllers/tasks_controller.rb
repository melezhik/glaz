class TasksController < ApplicationController


    def destroy
        @task = Task.find(params[:id])
        @task.destroy
        flash[:notice] = "task ID:#{params[:id]} has been successfully removed"
        redirect_to :back
    end

end
