class ImagesController < ApplicationController

    skip_before_filter :authenticate_user!, :only => [ :destroy ]

    load_and_authorize_resource param_method: :_params

    def index
        @report = Report.find(params[:report_id])
        @images = @report.images.order( :id => :desc )
    end


    def show
        @report = Report.find(params[:report_id])
        @image = Image.find(params[:id])
    end

    def view
        @report = Report.find(params[:report_id])
        @image = Image.find(params[:id])
        @stats = @image.stats
        render 'reports/view'
    end


    def destroy

        @report = Report.find(params[:report_id])
        @image = Image.find(params[:id])
        @image.destroy

        flash[:notice] = "image ID:#{params[:id]} has been successfully removed"

        if request.env["HTTP_REFERER"].nil?
            render  :text => "iamge ID:#{params[:id]} has been successfully removed\n"
        else
            redirect_to :back 
        end
    end

end
