class HostsController < ApplicationController

    def index
        @hosts = Host.all
    end

    def new
        @host = Host.new
    end

    def create
        @host = Host.new _params
        @host.save!
        redirect_to @host
    end

    def show
        @host = Host.find(params[:id])
    end

    def destroy
        @host = Host.find(params[:id])
        @host.destroy
        flash[:notice] = "host ID :#{params[:id]} has been successfully deleted"
        redirect_to hosts_url
    end

    def update

        @host = Host.find(params[:id])

        if @host.update _params
            flash[:notice] = "host ID: #{@host.id} has been successfully updated"
            redirect_to @host
        else 
            flash[:alert] = "error has been occured when update host ID: #{@host.id}"
            render 'edit'
        end

    end

    def edit
        @host = Host.find(params[:id])
    end


    def add_metric_form
        @host = Host.find(params[:id])
        @metrics = Metric.all.map { |i| a = Array.new; a.push i.title; a.push i.id; a }
        @task = Task.new
    end

    def metric
        @host = Host.find(params[:id])
        @metric = Metric.find(params[:metric_id])
        @task = Task.new :metric_id => params[:metric_id] , :host_id => params[:id]
        @task.save!
        flash[:notice] = "metrics ID :#{params[:metric_id]} has been successfully added to host ID : #{params[:id]}" 
        redirect_to @host
    end

private
    def _params
        params.require(:host).permit( 
                :title, :fqdn
        )
    end
    
end
