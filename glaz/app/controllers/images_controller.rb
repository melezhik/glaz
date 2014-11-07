class ImagesController < ApplicationController

    skip_before_filter :authenticate_user!, :only => [ :destroy ]

    load_and_authorize_resource param_method: :_params

    def index
        @report = Report.find(params[:report_id])
        @images = @report.images.order( :id => :desc )
    end


    def show
        @report = Report.find(params[:report_id])
        @image = Image.find(params[:id])
        @data =  @image.nil? ? [] : @image.data

        if @image.has_handler?

            handler = @image.handler

            logger.info "applying image handler"

            begin

                self.instance_eval handler
                logger.info "successfully executed report handler"

            rescue Exception => ex

                logger.error "handler execution failed. #{ex.class}: #{ex.message}"
                # raise "#{ex.class}: #{ex.message}"

            end
        else
            logger.info "report has no handler"
        end


        render 'reports/view'
    end

    def stat
        @report = Report.find(params[:report_id])
        @image = Image.find(params[:id])
    end


    def destroy

        @report = Report.find(params[:report_id])
        @image = Image.find(params[:id])
        @image.destroy

        flash[:notice] = "image ID:#{params[:id]} has been successfully removed"

        if request.env["HTTP_REFERER"].nil?
            render  :text => "iamge ID:#{params[:id]} has been successfully removed\n"
        else
            redirect_to :back 
        end
    end

end
