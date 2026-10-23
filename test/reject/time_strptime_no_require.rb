# Time.strptime without `require "time"`, same as Time.parse (K-001): a
# compile-time refusal naming the documented limit. With the require, it is
# CRuby's time.rb (test/time_strptime.rb).
# spinel: reject-time-parse: Time.strptime is not supported

def read_log_line(s)
  t = Time.strptime(s, "%Y-%m-%d")
  p t
end

read_log_line("2024-01-01")
