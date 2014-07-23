class ReportsController < ApplicationController

    def index
        @reports = Report.all
    end

    def new
        @report = Report.new
    end

    def create
        @report = Report.new _params
        @report.save!
        redirect_to @report
    end

    def show
        @report = Report.find(params[:id])
    end

    def destroy
        @report = Report.find(params[:id])
        @report.destroy
        flash[:notice] = "report ID :#{params[:id]} has been successfully deleted"
        redirect_to reports_url
    end

    def update

        @report = Report.find(params[:id])

        if @report.update _params
            flash[:notice] = "report ID: #{@report.id} has been successfully updated"
            redirect_to @report
        else 
            flash[:alert] = "error has been occured when update report ID: #{@report.id}"
            render 'edit'
        end

    end

    def edit
        @report = Report.find(params[:id])
    end


    def add_host_form
        @report = Report.find(params[:id])
        @hosts = Host.all.map { |i| a = Array.new; a.push "#{i.fqdn} : <#{i.title}>"; a.push i.id; a }
    end

    def host
        @report = Report.find(params[:id])
        @host = Host.find(params[:host_id])
        @point = Point.new :host_id => params[:host_id] , :report_id => params[:id]
        @point.save!
        flash[:notice] = "host ID :#{params[:host_id]} has been successfully added to report ID : #{params[:id]}" 
        redirect_to @report
    end

private
    def _params
        params.require(:report).permit( 
                :title
        )
    end

end