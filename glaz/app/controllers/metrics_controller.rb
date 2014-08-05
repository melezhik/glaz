class MetricsController < ApplicationController

    load_and_authorize_resource param_method: :_params

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

        Submetric.all.where( ' sub_metric_id = ? ', params[:id] ).each do |sm|
            logger.debug "remove related link to metric <#{@metric.title}> from group <#{sm.metric.title}>"
            sm.destroy            
        end

        Task.all.where( ' metric_id = ? ', params[:id] ).each do |t|
            logger.debug "remove related task ID: #{t.id}"
            t.destroy            
        end

        Xpoint.all.where( ' metric_id = ? ', params[:id] ).each do |p|
            logger.debug "remove related xpoint ID: #{p.id}"
            p.destroy
        end

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
                :title, :command, :default_value, :command_type, :handler
        )
    end

end
