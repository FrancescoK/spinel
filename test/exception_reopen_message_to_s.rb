# A builtin exception reopening's #to_s / #message: #message is the nearest
# reopening's #message, else its #to_s (Exception#message calls #to_s), else
# the stored message -- on a rescued, a constructed and a poly exception.
class StandardError
  def to_s = "<" + super + ">"
end
class IndexError
  def message = "IX[" + to_s + "]"
end
class MyErr < RuntimeError; end
class Own < StandardError
  def to_s = "own"
end
begin; raise MyErr, "m"; rescue => e; puts e.message; end
begin; {}.fetch(:z); rescue => e; puts e.message; puts e.to_s; end
begin; raise Own, "o"; rescue => e; puts e.message; end
begin; raise NotImplementedError, "n"; rescue ScriptError => e; puts e.message; end
xs = [RuntimeError.new("p"), KeyError.new("k"), 1]
xs.each { |x| puts x.respond_to?(:message) ? x.message : x }
class LoadError
  def detail = "LE: #{message}"
end
begin; raise LoadError, "lf"; rescue LoadError => e; puts e.detail; end
