# The load record keeps two same-named nested classes apart
# (--dump-load-record, record_nest_main.rb.load-record): A::Inner and
# B::Inner, reopened through an `A::Inner` header, each with its own
# methods; and each file's top level starts with private visibility, so a
# bare `public` in a required file does not reach the entry's top level.
module A
  class Inner
    def who = "A"
  end
end
module B
  class Inner
    def who = "B"
  end
end
require_relative "record_nest_lib"
class A::Inner
  def more = "A more"
end
def entry_helper = "private"
puts A::Inner.new.who
puts B::Inner.new.who
puts A::Inner.new.more
puts lib_helper
puts entry_helper
puts B::Inner.new.respond_to?(:more)
