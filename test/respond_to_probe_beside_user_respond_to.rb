# A class defining its own respond_to? -- activesupport's TimeWithZone --
# used to switch off the compile-time probes for EVERY respond_to? in the
# program, and a `respond_to?` on an exception, a String or an Array was then
# refused outright ("unsupported call"). The probes stay for every receiver
# but that class's instances.

class Dyn
  def respond_to?(m, include_all = false) = m == :magic || m == :to_s
end

e = LoadError.new("x")
p e.respond_to?(:zzz), e.respond_to?(:message)
p(e.respond_to?(:path) ? e.path.inspect : e.message)
p "str".respond_to?(:upcase), "str".respond_to?(:zzz)
p [1].respond_to?(:each), [1].respond_to?(:zzz)
p 3.respond_to?(:succ), 3.respond_to?(:zzz)
