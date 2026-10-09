# spinel: gc-stress
# spinel: share
# A modifier rescue keeps the cause the exception it catches already has:
# raised again while another exception is handled, as a statement and as a
# value, and with `cause: nil`. An explicit `cause:` still replaces it, also
# on the copy a frozen exception is raised as.
def with_cause(c)
  e = RuntimeError.new("e")
  begin
    raise e, cause: c
  rescue
  end
  e
end

seed = RuntimeError.new("seed")
other = RuntimeError.new("other")

x = with_cause(seed)
begin
  raise "handled"
rescue
  (raise x) rescue nil
  v = ((raise x) rescue 1)
  p [v, x.cause.equal?(seed)]
end

e = with_cause(seed)
(raise e, cause: nil) rescue nil
p e.cause.equal?(seed)

e = with_cause(seed)
(raise e, cause: other) rescue nil
p e.cause.equal?(other)
e = with_cause(seed)
w = ((raise e, cause: other) rescue 2)
p [w, e.cause.equal?(other)]

e = with_cause(seed)
e.freeze
v = ((raise e, cause: other) rescue $!.cause.equal?(other))
p [v, e.cause.equal?(seed)]
