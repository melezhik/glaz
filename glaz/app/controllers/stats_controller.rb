class StatsController < ApplicationController

    skip_before_filter :authenticate_user!, :only => [ :destroy ]

    load_and_authorize_resource param_method: :_params

    def index
        @report = Report.find(params[:report_id])
        @image = Image.find(params[:image_id])
        @stats = @image.stats.order( :id => :desc )
    end
    
    def show
        @report = Report.find(params[:report_id])
        @image = Image.find(params[:image_id])
        @stat = Stat.find(params[:id])
    end

    def destroy

        @stat = Stat.find(params[:id])

        @stat.destroy

        flash[:notice] = "stat ID:#{params[:id]} has been successfully removed"

        if request.env["HTTP_REFERER"].nil?
            render  :text => "stat ID:#{params[:id]} has been successfully removed\n"
        else
            redirect_to :back 
        end
    end

end
