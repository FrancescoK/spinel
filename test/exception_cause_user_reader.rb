# A method of an exception subclass, an attr_reader among them, answers on
# an exception typed only as one: a cause, a bare rescue's binding (#8376).
# Another class without it raises NoMethodError there.
class CodeError < StandardError
  attr_reader :code
  def initialize(code) = (super("code #{code}"); @code = code)
  def twice = code * 2
end
class Other < StandardError; end
begin
  begin
    raise CodeError.new(1)
  rescue CodeError
    raise CodeError.new(2)
  end
rescue CodeError => e
  p e.cause&.code, e.cause&.twice
end
def go(n) = raise(n == 1 ? CodeError.new(5) : Other.new("o"))
[1, 2].each do |n|
  begin
    go(n)
  rescue => e
    begin
      p e.code
    rescue NoMethodError => x
      p x.message
    end
  end
end
begin
  raise CodeError.new(3)
rescue CodeError => e
  p e.cause&.code, e.cause&.twice
end
