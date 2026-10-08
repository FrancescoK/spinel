# Time.parse is not implemented: a compile-time refusal naming the
# documented limit, not a run-time NoMethodError the first time the line
# runs (K-001). Same refusal whether or not `require "time"` was written,
# since neither path implements the string-parsing additions.
def read_log_line(s)
  t = Time.parse(s)
  p t
end

read_log_line("2024-01-01")
