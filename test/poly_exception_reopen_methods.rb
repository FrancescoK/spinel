# Methods a builtin exception class's reopening adds are reached through a
# run-time-typed (poly) receiver too: respond_to? sees them and the dispatch
# picks the reopening by the value's runtime class, for the builtin
# exceptions the runtime raised and for user subclasses alike.
class KeyError
  def hint = "key=#{key.inspect}"
end
class Exception
  def brief = "#{self.class.name}: #{message}"
end
class MyError < StandardError; end

errs = []
begin; { a: 1 }.fetch(:b); rescue KeyError => e; errs << e; end
begin; raise MyError, "mine"; rescue MyError => e; errs << e; end
begin; Integer("zz"); rescue ArgumentError => e; errs << e; end
errs << "not an exception"

errs.each { |x| p x.respond_to?(:brief) }
errs.each { |x| p x.respond_to?(:hint) }
errs.each { |x| p(x.respond_to?(:brief) ? x.brief : x) }
p errs[0].hint
