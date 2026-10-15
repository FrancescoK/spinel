# respond_to? with the name in a variable answers for a Method and an
# UnboundMethod as the literal form does: their own names true, a name they
# lack false. Before, every name of their own answered false, so observer's
# add_observer(method(:x), :call) raised NoMethodError.
def show(v) = v

def asks(obj, name) = obj.respond_to?(name)

m = method(:show)
u = m.unbind
%i[call [] << >> arity curry name original_name owner parameters receiver
   source_location super_method to_proc unbind to_s nope bind].each do |n|
  p [n, m.respond_to?(n), asks(m, n)]
end
%i[arity bind bind_call name original_name owner parameters source_location
   super_method to_s nope call].each do |n|
  p [n, u.respond_to?(n), asks(u, n)]
end

f = :call
p 1.method(:+).respond_to?(f), "x".method(:upcase).respond_to?(f)
p [m, proc { }, 1, "s"].map { |o| o.respond_to?(f) }
