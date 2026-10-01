# Reopening a builtin exception class adds methods to the builtin: the class
# stays the runtime's (raise, new, rescue and is_a? all see the real
# LoadError), and the added methods run on any instance, including the ones
# the runtime itself raised (activesupport's core_ext/load_error.rb,
# core_ext/name_error.rb).
class LoadError
  def is_missing?(location)
    location.delete_suffix(".rb") == path.to_s.delete_suffix(".rb")
  end
  def tag = "LE:#{message}"
end

class KeyError
  def hint = "key=#{key.inspect}"
end

class NameError
  def missing_name = "mn:#{name}"
end

begin
  raise LoadError, "m"
rescue LoadError => e
  p e.message, e.tag, e.is_a?(LoadError), e.is_a?(ScriptError), e.class
end

def f = raise(LoadError, "n")
begin
  f
rescue LoadError => e
  p e.message
end

begin
  raise LoadError
rescue LoadError => e
  p e.message
end

le = LoadError.new("z")
p le.tag, le.is_missing?("z"), le.is_a?(StandardError), le.is_a?(Exception)

begin
  raise le
rescue LoadError => e
  p e.tag
end

def chk(s)
  raise NameError.new("invalid: #{s}") unless /\A\w+\z/.match?(s)
  s
end
begin
  chk("a b")
rescue NameError => e
  p e.message
end

begin
  { a: 1 }.fetch(:b)
rescue KeyError => k
  p k.hint, k.message
end

begin
  raise NameError.new("who", :zork)
rescue NameError => e
  p e.missing_name
end
