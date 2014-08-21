class ImagesController < ApplicationController

    skip_before_filter :authenticate_user!, :only => [ :destroy ]

    load_and_authorize_resource param_method: :_params

    def index
        @report = Report.find(params[:report_id])
        @images = @report.images.order( :id => :desc )
    end


end
