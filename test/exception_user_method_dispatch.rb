# A user exception's own methods dispatch on its runtime class: #message on a
# boxed exception answers a user #to_s, #inspect renders it, and a subclass
# override is picked on a statically typed rescue variable.

class WriteError < StandardError
  def to_s = "top"
  def label = "base"
end

class DeepError < WriteError
  def to_s = "deep!"
  def label = "deep"
end

class DeepestError < DeepError
  def label = "deepest"
end

class CodeError < StandardError
  attr_reader :code
  def initialize(code)
    @code = code
    super("code #{code}")
  end
  def label = "code#{@code}"
end

class CodeSub < CodeError
  def label = "sub#{code}"
end

module Runner
  def run
    yield
  rescue StandardError => e
    puts e.message
    puts e.to_s
    p e
  end
end

class Job
  include Runner
end

Job.new.run { raise WriteError }
Job.new.run { raise DeepError }
Job.new.run { raise CodeSub.new(3) }
Job.new.run { raise "plain" }

[WriteError, DeepError, DeepestError].each do |k|
  begin
    raise k
  rescue WriteError => e
    puts e.label
    puts e.message
    puts e.to_s
    puts e.inspect
    puts e.detailed_message
  end
end

begin
  raise CodeSub.new(7)
rescue CodeError => e
  puts e.label
  puts e.message
  puts e.code
end

begin
  raise WriteError, "given"
rescue => e
  puts e.message
end
