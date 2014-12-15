Delayed::Worker.destroy_failed_jobs = true
Delayed::Worker.logger = Syslogger.new
Delayed::Worker.read_ahead = 1
Delayed::Worker.sleep_delay = 0
