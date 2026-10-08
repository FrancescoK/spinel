# A braceless Hash bound to a positional keeps the Strings in its values.
class Headers
  def initialize(headers = nil)
    headers.each { |key, value| value << '!' } unless headers.nil?
  end
end
value = +'header'
Headers.new('name' => value)
p value

def append_values(headers)
  headers.each { |key, value| value << '?' }
end
ordinary = +'method'
append_values('name' => ordinary)
p ordinary

# A declared keyword still binds its value rather than the whole Hash.
def append_keyword(text:)
  text << '.'
end
keyword = +'keyword'
append_keyword(text: keyword)
p keyword
Headers.new
