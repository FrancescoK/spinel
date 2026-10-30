# A required library whose classes the program never names compiles none of
# their methods: date's Date#<=> and Date.civil were kept because `<=>` and
# `new` are called somewhere, and every initialize was reached (#10592). The
# body of class Date still runs as the program loads, so the singleton method
# it calls there stays.
# absent: sp_Date_s_civil sp_Date__lt_set_gt sp_Date_jd
# present: sp_Date_s_compute_3key
require "date"
puts "x"
