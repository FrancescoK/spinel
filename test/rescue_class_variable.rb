# A rescue clause naming a class held in a variable, or returned by a call,
# matches by that class at run time. It used to match every exception.
class AppError < StandardError; end
class OtherError < StandardError; end

caught = ArgumentError
begin
  raise TypeError, "t"
rescue caught
  p :wrong
rescue TypeError
  p :right
end

begin
  raise ArgumentError, "a"
rescue caught => e
  p [:caught, e.class, e.message]
end

# a superclass held in a variable also catches a subclass
base = StandardError
begin
  raise AppError, "sub"
rescue base => e
  p [:base, e.class]
end

def pick(n) = n > 0 ? KeyError : IndexError
begin
  raise KeyError, "q"
rescue pick(1)
  p :call
end

# a class that does not match lets the exception pass to the outer clause
begin
  begin
    raise OtherError, "o"
  rescue caught
    p :wrong
  end
rescue AppError
  p :wrong
rescue OtherError => e
  p [:outer, e.message]
end

# a user class chosen at run time
chosen = ARGV.empty? ? AppError : OtherError
begin
  raise AppError, "u"
rescue OtherError
  p :wrong
rescue chosen
  p :chosen
end

# an operand that is not a class or module is a TypeError, an Array included
class Plain; end
def probe(label, operand)
  begin
    raise ArgumentError, "a"
  rescue operand
    p [label, :wrong]
  end
rescue TypeError => e
  p [label, e.message]
end
probe(:nil, nil)
probe(:int, 1)
probe(:string, "s")
probe(:array, [ArgumentError])
probe(:object, Plain.new)
probe(:range, (1..2))
probe(:exception, ArgumentError.new("x"))
probe(:class, ArgumentError)
