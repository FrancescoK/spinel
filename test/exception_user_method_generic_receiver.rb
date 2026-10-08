# A method the program defines on its own exception classes, called on a
# value typed only as "some exception" -- a `rescue A, B => ex` or `rescue
# StandardError => ex` binding, or a parameter such a binding is passed to.
# The call was refused at compile time ("unsupported call ... ty18"), so
# under --defer-refusals the whole method raised, even on the paths that
# never reach the call (WEBrick's HTTPResponse#set_error, which every
# keep-alive close runs). It now dispatches on the exception's run-time
# class: the owning class's method (inherited, aliased, taking arguments),
# and NoMethodError for a builtin exception or a class without it.
class Status < StandardError
  def self.code = nil
  def code() self::class::code end
  alias to_i code
  def reason(prefix, sep: " ") = "#{prefix}#{sep}#{self.class.name}"
  def detail = "status"
end
class ClientError < Status; end
class NotFound < ClientError
  def self.code = 404
end
class Teapot < ClientError
  def self.code = 418
  def detail = :teapot
end
class Plain < StandardError; end
class EOFErr < StandardError; end

def set_error(ex)
  case ex
  when Status then p [:status, ex.code, ex.to_i, ex.reason("x", sep: ":"), ex.detail]
  else p [:other, ex.class, ex.message]
  end
end

[-> { raise EOFErr }, -> { raise NotFound }, -> { raise Teapot }, -> { raise "boom" }].each do |f|
  begin
    f.call
  rescue EOFErr, NotFound => ex
    set_error(ex)
  rescue StandardError => ex
    set_error(ex)
  end
end

# the binding itself, and a class (or builtin) without the method
[NotFound, Teapot, Plain, ArgumentError].each do |k|
  begin
    raise k
  rescue Status, Plain, ArgumentError => e
    begin
      p e.code
    rescue NoMethodError => ne
      p ne.message
    end
  end
end

# and no exception at all: $! outside a rescue is nil
begin
  $!.code
rescue NoMethodError => ne
  p ne.message
end
