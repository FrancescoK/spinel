# Time.parse without `require "time"`: a compile-time refusal naming the
# documented limit, not a run-time NoMethodError the first time the line
# runs (K-001). With the require, Time.parse is CRuby's time.rb
# (test/time_parse.rb).
# spinel: reject-time-parse: Time.parse is not supported
def read_log_line(s)
  t = Time.parse(s)
  p t
end

read_log_line("2024-01-01")
