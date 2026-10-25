# A program's respond_to_missing? on TrueClass or Object answers a Boolean's
# respond_to? for the names it claims.
class Object
  def respond_to_missing?(name, include_all = false)
    name.to_s.start_with?("ghost_") || super
  end
end
flag = ARGV.empty?
p [true.respond_to?(:ghost_a?), flag.respond_to?(:ghost_b?), false.respond_to?(:ghost_c?)]
