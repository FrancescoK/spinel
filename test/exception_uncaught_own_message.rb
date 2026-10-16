# An uncaught exception whose class defines #message prints what #message
# answers, as CRuby's report does, not the text stored at #new. Here the class
# builds its text from the arguments and stores none.
class ParseError < RuntimeError
  def initialize(*args)
    @args = args
  end

  def message
    "missing argument: #{@args.join(' ')}"
  end
end

begin
  raise ParseError.new("-x")
rescue ParseError => e
  puts e.message
end

puts "before"
raise ParseError.new("-y")
