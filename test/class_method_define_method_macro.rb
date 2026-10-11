# A class method, or a method of a module the class extends, that hands
# define_method a block under a name it computes, called with literal
# arguments in the class's own body: each call defines the methods a def
# written out would, the block's parameters the method's, and the macro's
# arguments the values the block reads. A block parameter of the macro
# argument's name is the method's own.
class Markdown
  EXTENSIONS = []
  DEFAULT_EXTENSIONS = [:github, :notes]

  def self.extension name
    EXTENSIONS << name

    define_method "#{name}?" do
      extension? name
    end

    define_method "#{name}=" do |enable|
      extension name, enable
    end
  end

  extension :css
  extension :github
  extension :notes

  def initialize(extensions = DEFAULT_EXTENSIONS)
    @extensions = extensions
  end

  def extension? name
    @extensions.include? name
  end

  def extension name, enable
    if enable then
      @extensions |= [name]
    else
      @extensions -= [name]
    end
  end
end

m = Markdown.new
p [m.github?, m.css?, m.notes?]
m.css = true
m.github = false
p [m.github?, m.css?]
p Markdown::EXTENSIONS

module Flags
  def flag(name, default)
    define_method("#{name}?") { @flags.fetch(name, default) }
    define_method("#{name}=") do |name|
      @last = name
    end
    define_method("#{name}_or") { |v = name, *rest, k: default, &blk| [v, rest, k, blk ? blk.call : nil] }
    define_singleton_method("#{name}_default") { default }
  end
end
class Opts
  extend Flags
  flag :color, true
  flag :pager, false
  def initialize = (@flags = {}; @last = nil)
  attr_reader :last
end
o = Opts.new
p [o.color?, o.pager?]
o.color = :z
p o.last
p o.color_or, o.pager_or(1, 2, k: 3) { 4 }
p [Opts.color_default, Opts.pager_default]

class Foo
  def self.prop(n)
    define_method(n) { n.to_s * 2 }
  end
  prop :x
end
p Foo.new.x
