# Reopenings of builtin exception classes that define the same name: the
# one nearest the runtime class up its ancestry answers, whatever order they
# were written in; super walks on to the next one above; respond_to? asks
# the runtime class.
class StandardError
  def tag = "SE:#{message}"
end

class IOError
  def to_s = "<" + super + ">"
end

class RuntimeError
  def tag = "RT:" + super
  def rt = "rt(#{message})"
end

class IndexError
  def tag = "IX:#{message}"
end

class StandardError
  def code = "se"
end

class RuntimeError
  def code = 42
end

class MyErr < RuntimeError
  def tag = "MY:" + super
end

class MyArg < ArgumentError
  def tag = "MA:" + super
end

begin; raise "boom"; rescue => e; puts e.tag; end
begin; raise ArgumentError, "a"; rescue => e; puts e.tag; puts e.respond_to?(:rt); end
begin; {}.fetch(:k); rescue => e; puts e.tag; puts e.respond_to?(:tag); end
begin; raise MyErr, "m"; rescue MyErr => e; puts e.tag; end
puts MyArg.new("g").tag
puts RuntimeError.new("x").tag
puts RuntimeError.new("x").respond_to?(:rt)
puts KeyError.new("y").respond_to?(:rt)
begin; raise IOError, "io"; rescue => e; puts e.to_s; end
xs = [RuntimeError.new("p"), ArgumentError.new("q"), KeyError.new("r"), 1]
xs.each { |x| puts(x.respond_to?(:tag) ? x.tag : "no:#{x}") }
xs.each { |x| puts x.respond_to?(:rt) }
# definers answering different types
begin; raise "c"; rescue => e; p e.code; end
begin; raise ArgumentError, "c"; rescue => e; p e.code; end
