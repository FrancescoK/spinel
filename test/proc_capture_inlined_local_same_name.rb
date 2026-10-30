# A yielding method with a local `block` (and `options`) inlined inside a
# proc that captures the caller's `&block` and `options`: the nested proc
# of the inlined body captures the INLINED locals, but was filled from the
# enclosing proc's capture cells of the same names (a Proc's cell where
# a boxed value's was declared: incompatible pointer types in the C).
class Coll
  def initialize(a) = @a = a
  def each
    @a.each { |x| yield x }
    self
  end
end
class Mapper
  def initialize; @scope = {}; end
  def scope(opts)
    options = opts.dup
    scope = {}
    if options[:constraints].is_a?(Hash)
      options[:defaults] = options[:constraints]
    else
      block, options[:constraints] = options[:constraints], {}
    end
    keys = ARGV.empty? ? [:blocks, :options] : Coll.new([:blocks])
    keys.each do |option|
      value = option == :blocks ? block : options
      scope[option] = value
    end
    @scope = scope
    yield
    self
  end
  def leaf(name, &block)
    puts "leaf #{name}"
    block&.call
  end
  def resource(name, **options, &block)
    scope(options) { public_send(:leaf, name, &block) }
  end
  def resources(names, **options, &block)
    names.each { |r| public_send(:resource, r, **options, &block) }
  end
  def scope_info = @scope
end
m = Mapper.new
names = ARGV.empty? ? [:a, :b] : Coll.new([:z])
m.resources(names, constraints: :c) { puts "blk" }
p m.scope_info
