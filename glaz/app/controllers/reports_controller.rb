class ReportsController < ApplicationController


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
        @tag_id =  ( params[:tag_id].nil? or params[:tag_id].empty? ) ? nil : params[:tag_id]
        @hosts = @report.hosts_list.map { |i|  i[:host]}
        @metrics =  @report.metrics_flat_list.map {|i| i[:metric]}        
        @data = {}
        
        @hosts.each do |h|
            @metrics.each do |m|
                known = h.metric_known?(m, @tag_id) 
                never_calculated = h.metric_never_calculated?(m, @tag_id) 
                item = {
                    :host => h, 
                    :metric => m, 
                    :known => known,
                    :status => h.metric_status(m, @tag_id), 
                    :status_desc => h.metric_status_as_text(m, @tag_id),  
                    :status_as_color =>  h.metric_status_as_color(m, @tag_id),  
                    :value => known ? ( never_calculated ? '?' : h.metric_value(m, @tag_id) ) :  '?!' ,
                    :build => h.metric_build(m, @tag_id).nil?  ? nil : h.metric_build(m, @tag_id),
                    :task => h.metric_task(m, @tag_id),
                    :default_value => m.default_value,
                    :timestamp => known ? h.metric_timestamp(m, @tag_id) : nil, 
                }

                if @data.has_key? h.id
                    @data[h.id][:stat] << item
                else
                    @data[h.id] = { :stat => [ item ], :host => h }
                end
            end
        end

=begin html

<% @metrics.each do |m| %>
<tr>
    <th class="text-info" title="<%= m.title %>" >
        <%= link_to m.name||m.title, metric_path(m), :title => m.title %>
    </th>
    <% @hosts.each do |h| %>

            <% status = h.metric_status(m, @tag_id)  %>
            <% status_desc = h.metric_status_as_text(m, @tag_id) %>
            <% value = h.metric_value(m, @tag_id)  %>

            <th><table><tr><td bgcolor="<%=  h.metric_status_as_color(m, @tag_id)  %>" width="10" height="10" title="status: <%= status_desc  %>"></td></tr></table>
                <% if status == -1 %>
                    <span title="status: <%= status_desc  %>">?!</span>
                <% elsif status == -2 %>
                   <small class="text-mute"><%= link_to h.metric_build(m, @tag_id).id, task_build_path( h.metric_task(m, @tag_id), h.metric_build(m, @tag_id) ), :title => 'see log data'    %></small>
                    <pre  title="status: <%= status_desc  %>. default value: <%= m.default_value %>. last update: <%=  time_ago_in_words(h.metric_timestamp(m, @tag_id)) %> ago" ><%= value %></pre>
                <% elsif status == -3 %>
                    <span title="status: <%= status_desc  %>">?</span>
                <% elsif status == -4 %>
                    <small class="text-mute"><%= link_to h.metric_build(m, @tag_id).id, task_build_path( h.metric_task(m, @tag_id), h.metric_build(m, @tag_id) ), :title => 'see log data'    %></small>
                    <pre  title="status: <%= status_desc  %>. last update: <%=  time_ago_in_words(h.metric_timestamp(m, @tag_id)) %> ago" ><%= value %></pre>
                <% elsif status == 1 %>
                    <small class="text-mute"><%= link_to h.metric_build(m, @tag_id).id, task_build_path( h.metric_task(m, @tag_id), h.metric_build(m, @tag_id
) ), :title => 'see log data'    %></small>
                    <pre  title="status: <%= status_desc  %>. last update: <%=  time_ago_in_words(h.metric_timestamp(m, @tag_id)) %> ago" ><%= value %></pre>
                <% end %>
            </th>
    <% end %>
</tr>
<% end %>

=end html

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

        if params[ :create_tag ]
            tag = @report.tags.create
        else
            tag = nil
        end

        env = {}
        env[ :notify ] = ( params[ :notify ].nil? or params[ :notify ].empty? ) ? false : true
        env[ :rails_root ] = root_url

        @report.hosts.each.select {|i| i.enabled? }.each  do |h|
            hlist = h.multi? ? h.subhosts_list : [h]
            hlist.each do |host|
                logger.info "going to synchronize host: #{host.fqdn} in report: #{@report.id}"
                h.active_tasks.each.select{ |t| @report.has_metric? t.metric }.each do |task|
                    if task.metric.has_sub_metrics?
                        logger.info "task has submetrics, running over them"
                        task.metric.submetrics.each do |sm|
                            build = task.builds.create :state => 'PENDING'
                            build.save!
                            Delayed::Job.enqueue( BuildAsync.new( host, sm.obj, task, build, tag, env ) )
                            logger.info "host ID: #{params[:id]}, build ID:#{build.id} has been successfully scheduled to synchronization queue"        
                        end
                    else
                        logger.info "task has single metric"
                        build = task.builds.create :state => 'PENDING'
                        build.save!
                        Delayed::Job.enqueue( BuildAsync.new( host, task.metric, task, build, tag, env  ) )
                        logger.info "host ID: #{params[:id]}, build ID:#{build.id} has been successfully scheduled to synchronization queue"        
                    end
                end
            end
        end

        flash[:notice] = "report ID: #{params[:id]} has been successfully scheduled to synchronization queue"

        if request.env["HTTP_REFERER"].nil?
            render  :text => "report ID: #{params[:id]} has been successfully scheduled to synchronization queue\n"
        else
            redirect_to :back
        end

    end

    def tag
    
        @report = Report.find(params[:id])
        tag = @report.tags.create
    
        @report.metrics_flat_list.each do |m|
            @report.hosts.each do |h|
                stat = h.metric_stat m[:metric], nil
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
