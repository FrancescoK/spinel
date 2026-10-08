# Constructor and super edges reach the original container stores.
class Headers
  def initialize(headers = nil)
    @headers = {}
    unless headers.nil?
      headers.each { |key, value| @headers[key] = value }
    end
  end
  def text
    @headers['name']
  end
end
module Requests
  class Direct < Headers
    def initialize(headers = nil)
      super(headers)
    end
  end
  class Forward < Direct
    def initialize(headers = nil)
      super
    end
  end
end
text = +'header'
headers = {'name' => text}
request = Requests::Forward.new(headers)
request.text << '!'
p text
literal = +'literal'
request = Requests::Direct.new('name' => literal)
request.text << '?'
p request.text
p literal

# Inherited initialization and a nested container keep their original Strings.
class Inherited < Headers
end
text = +'inherited'
item = Inherited.new({'name' => text})
item.text << '.'
p text

class Nested
  def initialize(values)
    values.each do |key, list|
      list.each { |part| part << '+' }
    end
  end
end
part = +'nested'
Nested.new({'name' => [part]})
p part

# A user new method answers before initialize; its body owns the argument.
class Factory
  def self.new(values)
    values['name']
  end
  def initialize(values)
    values.each { |key, value| value << 'wrong' }
  end
end
p Factory.new({'name' => 'factory'})

# Ordinary method super forwards the same container, including keywords.
class ChangeValues
  def change(values, mark: '!')
    values.each { |key, value| value << mark }
  end
end
class ForwardValues < ChangeValues
  def change(values, mark: '!')
    super
  end
end
class ExplicitValues < ChangeValues
  def change(values, mark: '!')
    super(values, mark: mark)
  end
end
value = +'method'
ForwardValues.new.change({'name' => value}, mark: '?')
ExplicitValues.new.change({'name' => value}, mark: '.')
p value
