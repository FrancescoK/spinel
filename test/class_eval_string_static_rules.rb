# A grafted class_eval string reads as the program's own code to every later
# pass: a block with its own rescue, a guarded def after it, a reopened
# builtin, the `&:sym` sugar. A `private :name` with arguments, and locals inside a def, read
# the same either way.
class String
  class_eval "def shout = upcase + '!'"
end
class Sink
  class_eval <<~RUBY
    def safe
      [1].map do |x|
        raise "bad"
      rescue
        x + 6
      end
    end
  RUBY
  class_eval "def level = 1"
  def level = 2 unless method_defined?(:level)
  OPS = %i[foo_bar baz]
  OPS.each do |o|
    class_eval "def #{o}_name = '#{o.capitalize}/#{o.upcase}'"
  end
  class_eval "def secret = 42; private :secret"
  class_eval "def ups(xs) = xs.map(&:upcase)", __FILE__, __LINE__
  class_eval "def total(xs) = (t = 0; xs.each { |v| t += v }; t)"
  def reveal = secret
end
class Sink
  class_eval "def level_twice = level * 2"
end
s = Sink.new
p "hi".shout, s.safe, s.level, s.level_twice
p s.foo_bar_name, s.baz_name, s.reveal, s.respond_to?(:secret), s.total([1, 2, 3])
p s.ups(%w[a b])
