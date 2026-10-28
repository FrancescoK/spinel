# The mixins of a class made, or reopened, under a condition are in its
# ancestors once that body runs, prepends as well as includes; one under a
# condition inside the body is left out when it does not run
module A; end
module B; end
module C; end
module D; end
module E; end
if ARGV.empty?
  class Foo; include A; include B; prepend C; include D if ARGV.size > 5; end
end
class Bar; end
if ARGV.empty?
  class Bar; prepend E; end
end
p [Foo, 1][0].ancestors.take(4), [Foo, 1][0].include?(D)
p [Bar, 1][0].ancestors.first(2)
