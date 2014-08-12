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

    def destroy

        @task = Task.find(params[:task_id])
        @build = Build.find(params[:id])

        Stat.all.where(' build_id = ?', params[:id]).each do |s|
            logger.debug "remove related stat ID: #{s.id}"
            s.destroy            
        end
        @build.destroy
        flash[:notice] = "build ID:#{params[:id]} has been successfully removed"
        redirect_to [@task, :builds]
    end

end
