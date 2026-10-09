# spinel: gc-stress
# spinel: share
# A rescue between a reject! or delete_if whose block raises and an
# enclosing ensure catches the exception; the ensure runs once, after it.
# A loop between them is such a frame too, and passes the same object on.
class CodeError < StandardError
  attr_reader :code
  def initialize(code)
    @code = code
    super("code #{code}")
  end
end

def prune
  begin
    begin
      values = [1, 2, 3]
      values.reject! { |v| raise CodeError.new(v) if v == 2; false }
    rescue CodeError => e
      p [:reject!, e.code, values]
    end
    begin
      values = [1, 2, 3]
      values.delete_if { |v| raise CodeError.new(v * 10) if v == 3; v == 1 }
    rescue CodeError => e
      p [:delete_if, e.code, values]
    end
    puts "after"
  ensure
    puts "ensure ran"
  end
end

prune

def prune_in_loop
  begin
    loop do
      values = [1, 2, 3]
      values.reject! { |v| raise CodeError.new(v * 100) if v == 3; false }
    end
  ensure
    puts "ensure ran"
  end
end

begin
  prune_in_loop
rescue CodeError => e
  p e.code
end
