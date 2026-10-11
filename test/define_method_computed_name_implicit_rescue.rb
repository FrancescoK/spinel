# A class method handing define_method a block under a computed name, where
# the block's body carries its own rescue, else or ensure without a
# `begin`: the generated method takes the clauses, not the block's `do`, its
# parameters and its `end`.
class Foo
  def self.ext(name)
    define_method("#{name}?") do
      "ok #{name}"
    rescue => e
      "rescued #{e.message}"
    end
    define_method("#{name}_fail") do
      raise "no #{name}"
    rescue => e
      "rescued #{e.message}"
    end
  end

  def self.parse(name)
    define_method("#{name}_int") do |x, y = 2|
      Integer(x) + y
    rescue ArgumentError
      "#{name} bad"
    else
      "#{name} else"
    ensure
      puts "ensure #{name}"
    end
  end

  def self.ensure_only(name)
    define_method("#{name}!") do
      "body #{name}"
    ensure
      puts "after #{name}"
    end
  end

  ext :foo
  parse :num
  ensure_only :done
end

f = Foo.new
puts f.foo?
puts f.foo_fail
p f.num_int("3")
p f.num_int("zz", 5)
puts f.done!
