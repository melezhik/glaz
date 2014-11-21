Delayed::Worker.destroy_failed_jobs = true
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'), 10, 1024*1000 )
Delayed::Worker.read_ahead = 1
Delayed::Worker.sleep_delay = 0
