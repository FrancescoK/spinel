# A subclass of Hash that calls only its own methods answers p, to_s, ==
# and respond_to? as its Hash does.
class Opts < Hash
  def describe = "opts"
end

o = Opts.new
p o.describe
p o
p o.to_s, o == {}, o.respond_to?(:describe), o.respond_to?(:keys), o.class
