class BuildsController < ApplicationController

    skip_before_filter :authenticate_user!, :only => [ :destroy ]

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

        # @task = Task.find(params[:task_id])
        @build = Build.find(params[:id])

        Stat.all.where(' build_id = ?', params[:id]).each do |s|
            logger.debug "remove related stat ID: #{s.id}"
            s.destroy            
        end

        @build.destroy
        flash[:notice] = "build ID:#{params[:id]} has been successfully removed"

        if request.env["HTTP_REFERER"].nil?
            render  :text => "build ID:#{params[:id]} has been successfully removed\n"
        else
            redirect_to :back 
        end
    end

end
