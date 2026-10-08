# A temporary exception's marked message read takes the same handle route.
class TemporaryProblem < StandardError
  def initialize(text)
    super(text)
    @detail = 7
  end
end

def temporary_message
  [TemporaryProblem.new(+"temporary").message]
end
text = temporary_message
text[0] << "?"
p text
