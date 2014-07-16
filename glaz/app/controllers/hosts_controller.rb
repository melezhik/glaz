class HostsController < ApplicationController

    def index
        @hosts = Host.all
    end

    def new
    end

    def create
        @host = Host.new _params
        @host.save
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


private
    def _params
        params.require(:host).permit( 
                :title, :fqdn
        )
    end
    
end
