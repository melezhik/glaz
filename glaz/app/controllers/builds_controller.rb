class BuildsController < ApplicationController

    def index
        @task = Task.find(params[:task_id])
        @builds = @task.builds.order( :id => :desc )
    end
    
    def show
        @task = Task.find(params[:task_id])
        @build = Build.find(params[:id])
        @logs = @build.logs
    end

end
