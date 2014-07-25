class PointsController < ApplicationController

    load_and_authorize_resource param_method: :_params

    def destroy
        @point = Point.find(params[:id])
        @point.destroy
        flash[:notice] = "point ID:#{params[:id]} has been successfully removed"
        redirect_to :back
    end

end
