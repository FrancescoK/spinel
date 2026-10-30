# A base exception class's own `message` call dispatches over its subclasses'
# overrides; with one override in the program answering no String, the call is
# boxed, and the receiver that has no override of its own still answers through
# the message helpers -- as a boxed value, the value such an override answers.
class TemplateError < StandardError
  def initialize(file); @file = file; super(); end
  def line_number
    regexp = /#{Regexp.escape(@file)}:(\d+)/
    $1 if message =~ regexp
  end
end
class SyntaxErrorInTemplate < TemplateError
  def initialize(file, code); @code = code; super(file); end
  def message
    "syntax error near #{@code}"
  end
end
class CodedError < StandardError
  def initialize(code); @code = code; super("coded"); end
  def message = @code
end
begin
  raise TemplateError.new("app.rb"), "boom at app.rb:42 here"
rescue TemplateError => e
  p e.line_number
end
begin
  raise SyntaxErrorInTemplate.new("app.rb", "x +")
rescue TemplateError => e
  p e.line_number
  puts e.message
end
p CodedError.new(7).message
