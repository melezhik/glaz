class ReportsController < ApplicationController


    skip_before_filter :authenticate_user!, :only => [:synchronize]

    load_and_authorize_resource param_method: :_params

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

    def view
        @report = Report.find(params[:id])
    end

    def destroy

        @report = Report.find(params[:id])

        Point.all.where( ' report_id = ? ', params[:id] ).each do |t|
            logger.debug "remove related point ID: #{t.id}"
            t.destroy            
        end

        Xpoint.all.where( ' report_id = ? ', params[:id] ).each do |t|
            logger.debug "remove related xpoint ID: #{t.id}"
            t.destroy            
        end

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

        if @report.has_host? @host
            flash[:warn] = "cannot add host ID:#{params[:host_id]} to report, host is already added!" 
        else
            @point = Point.new :host_id => params[:host_id] , :report_id => params[:id]
            @point.save!
            flash[:notice] = "host ID :#{params[:host_id]} has been successfully added to report ID : #{params[:id]}" 
        end
        redirect_to @report
    end

    def add_metric_form
        @report = Report.find(params[:id])
        @metrics = Metric.all.map { |i| a = Array.new; a.push "<#{i.title}>"; a.push i.id; a }
    end

    def metric

        @report = Report.find(params[:id])
        @metric = Metric.find(params[:metric_id])

        if @report.has_metric? @metric
            flash[:warn] = "cannot add metric ID:#{params[:metric_id]} to report, metric is already added!" 
        else
            @point = Xpoint.new :metric_id => params[:metric_id] , :report_id => params[:id]
            @point.save!
            flash[:notice] = "metric ID :#{params[:metric_id]} has been successfully added to report ID : #{params[:id]}" 
        end
        redirect_to @report
    end


    def synchronize


        @report = Report.find(params[:id])

        @report.hosts.each.select {|i| i.enabled? }.each  do |host|

            host.active_tasks.each do |task|
    
                if task.metric.has_sub_metrics?
                    logger.info "task has submetrics, running over them"
                    task.metric.submetrics.each do |sm|
                        build = task.builds.create :state => 'PENDING'
                        build.save!
                        Delayed::Job.enqueue( BuildAsync.new( host, sm.obj, task, build ) )
                        logger.info "host ID: #{params[:id]}, build ID:#{build.id} has been successfully scheduled to synchronization queue"        
                    end
                else
                    logger.info "task has single metric"
                    build = task.builds.create :state => 'PENDING'
                    build.save!
                    Delayed::Job.enqueue( BuildAsync.new( host, task.metric, task, build ) )
                    logger.info "host ID: #{params[:id]}, build ID:#{build.id} has been successfully scheduled to synchronization queue"        
                end
            end

        end

        flash[:notice] = "report ID: #{params[:id]} has been successfully scheduled to synchronization queue"
        redirect_to :back

    end

private
    def _params
        params.require(:report).permit( 
                :title
        )
    end

end
