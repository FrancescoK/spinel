# `raise klass, "INT"` with the class only known at run time resolves the
# signal name as the constant form does: "SIGINT", signo 2. It kept "INT"
# and signo 0.
def pick(k) = k
begin
  raise pick(SignalException), "INT"
rescue SignalException => e
  p [e.class, e.message, e.signo]
end
begin
  raise pick(ArgumentError), "boom"
rescue ArgumentError => e
  p [e.class, e.message]
end
