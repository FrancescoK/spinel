# A constant aliasing a module (`S = Web::Status`) reaches that module's
# classes through `S::Name` -- also a class whose name a builtin has too
# (webrick's HTTPStatus::EOFError), which must not answer as the builtin.
module Web
  module Status
    class EOFError < StandardError; end
    class NotFound < StandardError; end
  end
end
S = Web::Status
module App
  H = Web::Status
  def self.boom = raise(H::EOFError, "inner")
end

p S::EOFError, S::EOFError.superclass, S::EOFError == ::EOFError
p S::NotFound.superclass
begin
  raise S::EOFError, "mine"
rescue ::EOFError
  puts "caught as the builtin EOFError"
rescue Web::Status::EOFError => e
  p [e.class, e.message]
end
begin
  App.boom
rescue Web::Status::EOFError => e
  p [e.class, e.message]
end
p S::EOFError.new.is_a?(IOError)
