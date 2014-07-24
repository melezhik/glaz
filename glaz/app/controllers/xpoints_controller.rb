class XpointsController < ApplicationController

    def destroy
        @point = Point.find(params[:id])
        @point.destroy
        flash[:notice] = "xpoint ID:#{params[:id]} has been successfully removed"
        redirect_to :back
    end

end
