class LogsController < ApplicationController

    load_and_authorize_resource param_method: :_params

    def index
        @report = Report.find(params[:report_id])
        @image = Image.find(params[:image_id])
        @stat = Stat.find(params[:stat_id])
        @logs = @stat.logs
    end

end
