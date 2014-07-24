class XpointsController < ApplicationController

    def destroy
        @point = Xpoint.find(params[:id])
        @point.destroy
        flash[:notice] = "xpoint ID:#{params[:id]} has been successfully removed"
        redirect_to :back
    end

end
