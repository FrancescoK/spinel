# `k.new` on a value that may hold several classes fills each class's
# defaults in that class's own arm: one class's default (here a call that
# raises) runs only when that class is constructed, not ahead of the
# dispatch for every class. The value is a Class (make) or a box (make_from).
class Plain
  def initialize(escape: true) = @escape = escape
  def escape = @escape
end
class Wide
  def initialize(width: IO.no_such_size[1]) = @width = width
  def escape = @width
end
def make(k) = k.new
def make_from(h) = h[:k].new
p make([Plain, Wide][ARGV.size]).escape
p make_from({k: [Plain, Wide][ARGV.size]}).escape
begin
  make(Wide)
rescue NoMethodError => e
  puts e.class
end
