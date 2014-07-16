class MetricsController < ApplicationController

    def index
        @metrics = Metric.all
    end

    def new
    end

    def create
        @metric = Metric.new _params
        @metric.save!
        redirect_to @metric
    end

    def show
        @metric = Metric.find(params[:id])
    end

    def destroy
        @metric = Metric.find(params[:id])
        @metric.destroy
        flash[:notice] = "metric ID :#{params[:id]} has been successfully deleted"
        redirect_to metrics_url
    end

    def update

        @metric = Metric.find(params[:id])

        if @metric.update _params
            flash[:notice] = "metric ID: #{@metric.id} has been successfully updated"
            redirect_to @metric
        else 
            flash[:alert] = "error has been occured when update metric ID: #{@metric.id}"
            render 'edit'
        end

    end

    def edit
        @metric = Metric.find(params[:id])
    end


private
    def _params
        params.require(:metric).permit( 
                :title, :command, :default_value
        )
    end

end
