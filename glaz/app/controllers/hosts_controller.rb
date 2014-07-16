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


private
    def _params
        params.require(:host).permit( 
                :title, :fqdn
        )
    end
    
end
