class BuildsController < ApplicationController

    load_and_authorize_resource param_method: :_params

    def index
        @task = Task.find(params[:task_id])
        @builds = @task.builds.order( :id => :desc )
    end
    
    def show
        @task = Task.find(params[:task_id])
        @build = Build.find(params[:id])
    end

end
