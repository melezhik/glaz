class SubmetricsController < ApplicationController

    load_and_authorize_resource param_method: :_params

    def new
        @metric = Metric.find(params[:metric_id])
        @sub_metric = @metric.submetrics.new
        @sub_metrics = Metric.all.reject { |i| i.multi? }.reject{ |i| @metric.has_metric? i }.reject {|m| m.id == params[:metric_id].to_i}.map { |m| a = []; a << m.title; a << m.id; a  }
    end

    def create
        @metric = Metric.find(params[:metric_id])
        @sub_metric = Metric.find(params[:submetric][:sub_metric_id])

        if @sub_metric.multi?
            flash[:warn] = "cannot add multi metric ID:#{params[:submetric][:sub_metric_id]} as submetric" 
        elsif @metric.has_metric? @sub_metric
            flash[:warn] = "cannot add metric ID:#{params[:submetric][:sub_metric_id]} as submetric because host already has it" 
        else
            flash[:notice] = "sub metric ID :#{params[:submetric][:sub_metric_id]} has been successfully added to metric #{params[:metric_id]}" 
            @sub_metric = @metric.submetrics.create! _params
            @sub_metric.save!
        end
    
        redirect_to @metric
    end

    def destroy
        @metric = Metric.find(params[:metric_id])
        @sub_metric = Submetric.find(params[:id])
        @sub_metric.destroy
        flash[:notice] = "sub metric ID :#{params[:id]} has been successfully deleted"
        redirect_to @metric
    end

private
    def _params
        params.require( :submetric ).permit( 
                :sub_metric_id 
        )
    end

end
