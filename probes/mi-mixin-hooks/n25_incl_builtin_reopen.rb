# included: include into a reopened builtin class fires the hook
module M
  def self.included(b) = puts("inc #{b}")
  def shout = upcase + "!"
end
class String
  include M
end
puts "hi".shout
