# Discarding an inlined return's value still evaluates it before ensure.
def record(n)
  puts "record #{n}"
  n
end
class Parent
  def run(n)
    begin
      yield
      return record(1), record(2) if n > 0
      return record(3)
    ensure
      puts "ensure"
    end
  end
end
class Child < Parent
  def run(n)
    super(n) { puts "block" }
    nil
  end
end
Child.new.run(1)
Child.new.run(0)
def discard
  begin
    return puts("nil return")
  ensure
    puts "nil ensure"
  end
end
discard
