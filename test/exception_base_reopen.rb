# Reopening Exception (or StandardError) adds a method every exception
# inherits: builtin ones the runtime raised and user subclasses alike
# (activesupport's core_ext/object/json.rb gives Exception#as_json).
class Exception
  def as_json(options = nil) = { "class" => self.class.name, "message" => message }
end

class StandardError
  def brief = "#{self.class.name}: #{message}"
end

class MyError < StandardError
  def initialize(code)
    @code = code
    super("code #{code}")
  end
  attr_reader :code
end

begin
  raise MyError.new(7)
rescue MyError => e
  p e.as_json, e.brief, e.code
end

begin
  Integer("zz")
rescue ArgumentError => e
  p e.as_json, e.brief
end

begin
  raise "plain"
rescue => e
  p e.as_json
end

p RuntimeError.new("r").brief
