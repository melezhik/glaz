class ReportsController < ApplicationController


    include ActionController::Live

    skip_before_filter :authenticate_user!, :only => [ :synchronize ]

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
        @image = @report.images.last
        @data =  @image.nil? ?  [] : @image.data

    end

    def json

        @report = Report.find(params[:id])
        @image = @report.images.last
        @data =  @image.nil? ?  [] : @image.data
        response.headers['Content-Type'] = 'text/event-stream'
        response.headers['Cache-Control'] = 'no-cache'

#        sse = SSE.new(response.stream, retry: 300, event: "report-json")
        sse = SSE.new(response.stream, retry: 300)
        sse.write("hello100")
        sleep 5        
        render nothing: true
    ensure
        sse.close
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
        @metrics = Metric.all.map { |i| a = Array.new; a.push "#{i.title}"; a.push i.id; a }
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

        env = {}
        env[ :notify ] = ( params[ :notify ].nil? or params[ :notify ].empty? ) ? false : true
        env[ :rails_root ] = root_url

        image = @report.images.create( :keep_me =>  params[ :create_tag ] ? true : false )
        image.save!

        env[ :image_url ] = url_for [ @report, image ]


        @report.hosts.each.select {|i| i.enabled? }.each  do |h|

            hlist = h.multi? ? h.subhosts_list : [h]
            hlist.each do |host|

                logger.info "going to synchronize host: #{host.fqdn} in report: #{@report.id}"

                # { :point => point , :metric => sm.obj, :multi => true, :group => point.metric.title, :group_metric => sm.metric }

                @report.metrics_flat_list.map {|i| i[:metric] }.each do |m|
                
                task = nil; metric = nil

                h.active_tasks.select { |t| @report.has_metric? t.metric }.each do |t| 

                    if t.metric.has_sub_metrics?
                        t.metric.submetrics.each do |sm|
                            if sm.obj.id == m.id
                                metric = sm.obj
                                task = t 
                            end
                        end
                    else
                        if t.metric.id == m.id
                            task = t 
                            metric = t.metric
                        end
                    end
                end

                if task.nil?

                    logger.info "unknown metric found for host: #{host.fqdn}, metric: #{m.title}"
                    stat = image.stats.create( :timestamp =>  Time.now.to_i, :metric_id => m.id, :task_id => nil, :status => 'REPORT_ERROR', :host_id => host.id )

                else

                    stat = image.stats.create( :timestamp =>  Time.now.to_i, :metric_id => m.id, :task_id => task.id, :status => 'PENDING', :host_id => host.id )

                    stat.save!
    
                    Delayed::Job.enqueue( BuildAsync.new( host, metric, task, stat, env  ) )

                    logger.info "report ID: #{params[:id]}, stat ID:#{stat.id} has been successfully scheduled to synchronization queue"        
    
                end                

                end # next metric

            end # next host
        end


        flash[:notice] = "report ID: #{params[:id]} has been successfully scheduled to synchronization queue"

        if request.env["HTTP_REFERER"].nil?
            render  :text => "report ID: #{params[:id]} has been successfully scheduled to synchronization queue\n"
        else
            redirect_to  url_for([ @report, image ])
        end

    end

    def tag
    
        @report = Report.find(params[:id])
        tag = @report.tags.create
    
        @report.metrics_flat_list.each do |m|
            @report.hosts_list.each do |h|
                stat = h[:host].metric_stat m[:metric], nil
                if stat
                    stat.update :tag_id => tag.id
                    stat.save!
                end
            end
        end
    
        flash[:notice] = "report ID: #{params[:id]} has been successfully tagged"
        redirect_to :back
    
    end
    

private

    def _params
        params.require(:report).permit( 
                :title
        )
    end

end
