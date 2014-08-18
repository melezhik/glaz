class SubhostsController < ApplicationController


    load_and_authorize_resource param_method: :_params

    def new
        @host = Host.find(params[:host_id])
        @sub_host = @host.subhosts.new
        @sub_hosts = Host.all.reject { |i| i.multi? }.reject{ |i| @host.has_host? i }.reject {|m| m.id == params[:host_id].to_i}.map { |m| a = []; a << m.fqdn; a << m.id; a  }
    end

    def create
        @host = Host.find(params[:host_id])
        @sub_host = Host.find(params[:subhost][:sub_host_id])

        if @sub_host.multi?
            flash[:warn] = "cannot add multi host ID:#{params[:subhost][:sub_host_id]} as subhost" 
        elsif @host.has_host? @sub_host
            flash[:warn] = "cannot add host ID:#{params[:subhost][:sub_host_id]} as subhost because host already has it" 
        else
            flash[:notice] = "sub host ID :#{params[:subhost][:sub_host_id]} has been successfully added to host #{params[:host_id]}" 
            @sub_host = @host.subhosts.create! _params
            @sub_host.save!
        end
    
        redirect_to @host
    end

    def destroy
        @host = Host.find(params[:host_id])
        @sub_host = Subhost.find(params[:id])
        @sub_host.destroy
        flash[:notice] = "sub host ID :#{params[:id]} has been successfully deleted"
        redirect_to @host
    end

private
    def _params
        params.require( :subhost ).permit( 
                :sub_host_id 
        )
    end


end
