class SubMetricsController < ApplicationController

    def index
        @metric = Metric.find(params[:metric_id])
    end

    def new
        @metric = Metric.find(params[:metric_id])
        @metrics = Metric.all
        @sub_metric = @metric.sub_metrics.new
        @sub_metrics = @metrics.reject {|m| m.id == params[:metric_id].to_i}.map { |m| a = []; a << m.title; a << m.id; a  }
    end

    def create
        @metric = Metric.find(params[:metric_id])
        @sub_metric = @metric.sub_metrics.create! _params
        @sub_metric.save!
        redirect_to @metric
    end

    def destroy
        @metric = Metric.find(params[:metric_id])
        @sub_metric = SubMetric.find(params[:id])
        @sub_metric.destroy
        flash[:notice] = "sub metric ID :#{params[:id]} has been successfully deleted"
        redirect_to @metric
    end

private
    def _params
        params.require( :sub_metric ).permit( 
                :sub_metric_id 
        )
    end

end
