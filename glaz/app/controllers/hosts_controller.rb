class HostsController < ApplicationController

    def index
        @hosts = Host.all
    end

    def new
        @host = Host.new
    end

    def create
        @host = Host.new _params
        @host.save!
        redirect_to @host
    end

    def show
        @host = Host.find(params[:id])
    end

    def destroy
        @host = Host.find(params[:id])

        Task.all.where( ' host_id = ? ', params[:id] ).each do |t|
            logger.debug "remove related task ID: #{t.id}"
            t.destroy            
        end

        Point.all.where( ' host_id = ? ', params[:id] ).each do |p|
            logger.debug "remove related point ID: #{p.id}"
            p.destroy            
        end

        @host.destroy
        flash[:notice] = "host ID :#{params[:id]} has been successfully deleted"
        redirect_to hosts_url
    end

    def update

        @host = Host.find(params[:id])

        if @host.update _params
            flash[:notice] = "host ID: #{@host.id} has been successfully updated"
            redirect_to @host
        else 
            flash[:alert] = "error has been occured when update host ID: #{@host.id}"
            render 'edit'
        end

    end

    def edit
        @host = Host.find(params[:id])
    end


    def add_metric_form
        @host = Host.find(params[:id])
        @metrics = Metric.all.map { |i| a = Array.new; a.push i.title; a.push i.id; a }
    end

    def metric
        @host = Host.find(params[:id])
        @metric = Metric.find(params[:metric_id])
        if @host.has_metric? @metric
            flash[:warn] = "cannot add metric ID:#{params[:metric_id]}, metric is already added!" 
        else
            @task = Task.new :metric_id => params[:metric_id] , :host_id => params[:id]
            @task.save!
            flash[:notice] = "metrics ID :#{params[:metric_id]} has been successfully added to host ID : #{params[:id]}" 
        end
        redirect_to @host
    end


    def synchronize

        @host = Host.find(params[:id])

        if @host.enabled?
            @host.active_tasks.each do |task|
    
                if task.metric.has_sub_metrics?
                    logger.info "task has submetrics, running over them"
                    task.metric.submetrics.each do |sm|
                        build = task.builds.create :state => 'PENDING'
                        build.save!
                        Delayed::Job.enqueue( BuildAsync.new( @host, sm.obj, build ) )
                        logger.info "host ID: #{params[:id]}, build ID:#{build.id} has been successfully scheduled to synchronization queue"        
                    end
                else
                    logger.info "task has single metric"
                    build = task.builds.create :state => 'PENDING'
                    build.save!
                    Delayed::Job.enqueue( BuildAsync.new( @host, task.metric, build ) )
                    logger.info "host ID: #{params[:id]}, build ID:#{build.id} has been successfully scheduled to synchronization queue"        
                end
            end
    
            flash[:notice] = "host ID: #{params[:id]} has been successfully scheduled to synchronization queue"
        else
            flash[:warn] = "cannot synchronize disabled host ID: #{params[:id]}"
        end
        redirect_to :back
    end

private
    def _params
        params.require(:host).permit( 
                :title, :fqdn, :enabled
        )
    end
    
end
