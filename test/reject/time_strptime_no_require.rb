# Time.strptime is not implemented, same as Time.parse (K-001): a
# compile-time refusal naming the documented limit.
# spinel: reject-time-parse: Time.strptime is not supported
require "time"

def read_log_line(s)
  t = Time.strptime(s, "%Y-%m-%d")
  p t
end

read_log_line("2024-01-01")
