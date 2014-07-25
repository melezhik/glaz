class XpointsController < ApplicationController

    load_and_authorize_resource param_method: :_params

    def destroy
        @point = Xpoint.find(params[:id])
        @point.destroy
        flash[:notice] = "xpoint ID:#{params[:id]} has been successfully removed"
        redirect_to :back
    end

end
