l = "2014-08-03 20:00:38,689 INFO exited: gb_product_00 (exit status 104; not expected)"
m = / exited: (\S+)_\S+ \(exit status \d+;.*\)/.match l
puts 1 if m 



